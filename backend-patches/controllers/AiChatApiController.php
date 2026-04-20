<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\NongYingAIService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

/**
 * Cloud chat endpoint for "น้องหญิง".
 *
 * Routes to `NongYingAIService` which enumerates every active API key
 * in the `AiApiKeyPoolService`, tries Gemini-keys first, and
 * auto-fails-over to Groq / Grok / Qwen / OpenRouter / DeepSeek /
 * Typhoon on 429 or errors — the same rotation pattern that powers
 * FortuneAIService (ดูดวง) on this site.
 *
 * System prompt + persona live on an AiBotProfile row in the DB so
 * admin can tweak persona without a redeploy. The bot profile id is
 * stored in `app_configs.nong_ying_bot_profile_id`.
 *
 * Request:  POST /api/v1/ai/chat
 *   body:   { messages: [{role, content}], context?: {...} }
 * Response: { reply: string, provider: string, model: string,
 *             tokens_used: int, via: "pool_failover", keys_tried: int }
 */
class AiChatApiController extends Controller
{
    public function chat(Request $request, NongYingAIService $ai): JsonResponse
    {
        $data = $request->validate([
            'messages'           => 'required|array|min:1|max:20',
            'messages.*.role'    => 'required|in:user,assistant,system',
            'messages.*.content' => 'required|string|max:4000',
            'context'            => 'nullable|array',
        ]);

        // Split messages into history + prompt. Last user message is
        // the live prompt; the rest goes into history. System messages
        // on the wire are discarded — the real persona lives on the
        // bot profile.
        $message = '';
        $history = [];
        foreach ($data['messages'] as $m) {
            if ($m['role'] === 'system') continue;
            if ($m['role'] === 'user') {
                $message = $m['content']; // keep overwriting — last user wins
            }
            $history[] = ['role' => $m['role'], 'content' => $m['content']];
        }
        // Drop the trailing user turn from history so it isn't doubled.
        if (! empty($history) && end($history)['role'] === 'user') {
            array_pop($history);
        }

        if ($message === '') {
            return response()->json([
                'error' => 'no_user_message',
                'message' => 'กรุณาส่งข้อความก่อนนะคะ',
            ], 422);
        }

        $systemPrompt = $this->resolveSystemPrompt($data['context'] ?? []);

        // Auto-RAG: query the product catalog for items relevant to the
        // user's message and append up to 3 hints into the system
        // prompt. The model uses them to suggest real products with
        // accurate prices + [GO:/path] deep-links, rather than making
        // up names. Silently skip on any error — chat should still
        // work if the DB lookup fails.
        try {
            $hints = $this->retrieveKnowledge($message, 3);
            if (! empty($hints)) {
                $systemPrompt .= "\n\nข้อมูลที่เกี่ยวข้องในแอพ (ใช้ตอบลูกค้าได้ · ถ้าเกี่ยวข้อง · อย่าประดิษฐ์):\n" . $hints;
            }
        } catch (\Throwable $e) {
            Log::debug('[AiChat] knowledge retrieval skipped: ' . $e->getMessage());
        }

        try {
            $result = $ai->chat($message, $history, $systemPrompt, [
                'temperature' => 0.7,
                'max_tokens'  => 800,
            ]);

            return response()->json([
                'reply'        => $result['text'],
                'provider'     => $result['provider'] ?? null,
                'model'        => $result['model'] ?? null,
                'tokens_used'  => $result['tokens_used'] ?? 0,
                'keys_tried'   => $result['key_tried_count'] ?? 1,
                'response_ms'  => $result['response_time_ms'] ?? null,
                'via'          => 'pool_failover',
            ]);
        } catch (\Throwable $e) {
            report($e);
            Log::error('[AiChat] all keys failed', ['error' => $e->getMessage()]);
            return response()->json([
                'error'   => 'ai_pool_exhausted',
                'message' => 'น้องหญิงเจอปัญหานิดหน่อยค่ะ · ลองใหม่สักครู่นะคะ',
                'detail'  => config('app.debug') ? $e->getMessage() : null,
            ], 503);
        }
    }

    /**
     * Compose the system prompt that guides this turn. The bulk lives
     * on the bot profile (ai_bot_profiles.system_prompt) so admin can
     * edit via DB. We prepend a small context block with the current
     * screen so the model can suggest the right `[GO:/path]` link.
     */
    private function resolveSystemPrompt(array $context): string
    {
        $botProfileId = (int) DB::table('app_configs')
            ->where('key', 'nong_ying_bot_profile_id')
            ->where('environment', app()->environment())
            ->value('value');

        $base = '';
        if ($botProfileId > 0) {
            $base = (string) DB::table('ai_bot_profiles')
                ->where('id', $botProfileId)
                ->value('system_prompt');
        }
        if ($base === '') {
            // Safety fallback — hand-coded persona if DB row is missing.
            $base = <<<'TXT'
คุณคือ "น้องหญิง" ผู้ช่วยของ Thaiprompt (ตลาดชุมชนไทย).
กฎ: ใช้ "หนู", ลงท้าย "ค่ะ/คะ/นะคะ", ห้ามใช้ "ครับ". เป็นผู้หญิง สุภาพ สดใส.
ตอบสั้น 2-3 ประโยค. ใช้ [GO:/path] เมื่อพาไปหน้าในแอพ (/home, /taladsod, /wallet, /cart ...).
TXT;
        }

        if (empty($context)) return $base;

        $lines = [];
        foreach ($context as $k => $v) {
            if (is_scalar($v) || $v === null) {
                $lines[] = "  {$k}: " . ($v ?? '-');
            } else {
                $lines[] = "  {$k}: " . json_encode($v, JSON_UNESCAPED_UNICODE);
            }
        }
        return $base . "\n\nบริบทปัจจุบัน:\n" . implode("\n", $lines);
    }

    /**
     * Quick product/category lookup for the current user message.
     * Returns a plaintext block formatted for inclusion in the system
     * prompt, or an empty string when nothing matches.
     *
     * Intentionally light — we don't tokenise or stem, just LIKE-scan
     * the user message verbatim. Works well enough for Thai which
     * doesn't have natural whitespace between words. A FULLTEXT index
     * + Thai word segmentation are the obvious follow-ups.
     */
    private function retrieveKnowledge(string $message, int $limit): string
    {
        if (mb_strlen($message) < 2 || mb_strlen($message) > 160) return '';

        $hits = [];

        // Products first (93 rows live) — filter active ones.
        $products = DB::table('products')
            ->where('is_active', 1)
            ->where(function ($w) use ($message) {
                $w->where('name', 'like', '%' . $message . '%')
                  ->orWhere('short_description', 'like', '%' . $message . '%');
            })
            ->limit($limit)
            ->get(['id', 'name', 'price', 'compare_at_price', 'stock_quantity']);
        foreach ($products as $p) {
            $price = number_format((float) $p->price, 0);
            $stock = $p->stock_quantity > 0 ? "เหลือ {$p->stock_quantity}" : 'หมด';
            $hits[] = "• [product] {$p->name} · ฿{$price} · {$stock} · [GO:/product/{$p->id}]";
        }

        // Fresh-market categories when user asks about "ผัก" / "ผลไม้"
        $categories = DB::table('fresh_market_categories')
            ->where('is_active', 1)
            ->where('name', 'like', '%' . $message . '%')
            ->limit($limit)
            ->get(['id', 'name', 'description']);
        foreach ($categories as $c) {
            $desc = $c->description ? ' · ' . mb_substr($c->description, 0, 60) : '';
            $hits[] = "• [หมวดตลาดสด] {$c->name}{$desc} · [GO:/taladsod/listings?category={$c->id}]";
        }

        return implode("\n", array_slice($hits, 0, $limit));
    }
}
