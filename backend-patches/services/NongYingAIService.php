<?php

namespace App\Services;

use App\Models\AiApiKey;
use Exception;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

/**
 * Cloud chat brain for "น้องหญิง".
 *
 * Mirrors the battle-tested fallback pattern in FortuneAIService:
 *
 *   1. Enumerate ALL usable API keys across ALL providers from the
 *      `AiApiKeyPoolService`. Keys of the "primary" provider (Gemini
 *      by default) come first, then everything else.
 *   2. Try keys in order. On success → record token usage on the key,
 *      return the reply.
 *   3. On failure: record the error on the key, wait 1s if 429 /
 *      rate-limited (fast failover), 3s otherwise, then try the next.
 *   4. Only fail when every key is exhausted.
 *
 * This service is chat-focused (unlike FortuneAIService which also
 * handles fortune-reading prompt templates). The system prompt +
 * message history are passed in, persona lives in the caller's
 * AiBotProfile so admin can edit without redeploying.
 */
class NongYingAIService
{
    protected AiApiKeyPoolService $pool;

    /** Ordered list of providers we know how to call below. When
     *  `primary` is missing from the pool we still try every other
     *  provider, so this is effectively the preferred-first ordering. */
    private const PROVIDER_ORDER = [
        'gemini',       // Google Gemini — primary (cheap, fast, good Thai)
        'groq',         // Groq (Llama 3.1/3.3) — very fast fallback
        'grok',         // xAI Grok
        'openrouter',   // OpenRouter (routes to any model)
        'qwen',         // Alibaba Qwen
        'deepseek',     // DeepSeek
        'typhoon',      // SCB 10X Typhoon (Thai-first)
    ];

    /** Default model per provider when the pool key doesn't pin one. */
    private const DEFAULT_MODELS = [
        'gemini'     => 'gemini-2.5-flash',
        'groq'       => 'llama-3.3-70b-versatile',
        'grok'       => 'grok-2-latest',
        'qwen'       => 'qwen-plus',
        'openrouter' => 'google/gemini-2.5-flash',
        'deepseek'   => 'deepseek-chat',
        'typhoon'    => 'typhoon-v2-70b-instruct',
    ];

    public function __construct(?AiApiKeyPoolService $pool = null)
    {
        $this->pool = $pool ?? new AiApiKeyPoolService;
    }

    /**
     * Main entry point — chat with auto-failover across the AI pool.
     *
     * @param  string  $message        current user message
     * @param  array   $history        list of {role: user|assistant, content: string}
     * @param  string  $systemPrompt   persona + app map (from bot profile)
     * @param  array   $options        {temperature?, max_tokens?}
     * @return array {text, provider, model, tokens_used, key_tried_count}
     * @throws Exception when every key fails
     */
    public function chat(string $message, array $history, string $systemPrompt, array $options = []): array
    {
        $temperature = $options['temperature'] ?? 0.7;
        $maxTokens   = $options['max_tokens'] ?? 800;

        $allKeys = $this->getAllAvailableKeys();
        if (empty($allKeys)) {
            throw new Exception('ไม่มี API Key ที่พร้อมใช้งานใน Pool · admin ต้องเพิ่ม key ก่อน');
        }

        $errors = [];
        $startTime = microtime(true);

        foreach ($allKeys as $i => $keyInfo) {
            $label = "{$keyInfo['provider']}/{$keyInfo['name']}";
            $total = count($allKeys);
            $n = $i + 1;
            Log::info("NongYingAI: ลอง key [{$n}/{$total}] {$label}");

            try {
                $result = $this->callProvider(
                    $keyInfo['provider'],
                    $keyInfo['api_key'],
                    $keyInfo['model'] ?? self::DEFAULT_MODELS[$keyInfo['provider']] ?? '',
                    $message,
                    $history,
                    $systemPrompt,
                    ['temperature' => $temperature, 'max_tokens' => $maxTokens]
                );

                $responseMs = (int) ((microtime(true) - $startTime) * 1000);

                if ($keyInfo['pool_key'] instanceof AiApiKey) {
                    try {
                        $keyInfo['pool_key']->recordUsage(
                            $result['input_tokens'] ?? 0,
                            $result['output_tokens'] ?? 0,
                            $result['model'] ?? $keyInfo['model'] ?? null,
                            $responseMs,
                            'nong_ying_chat'
                        );
                    } catch (\Throwable $e) {
                        Log::warning('NongYingAI: recordUsage failed · ' . $e->getMessage());
                    }
                }

                Log::info("NongYingAI: สำเร็จ [{$n}/{$total}] {$label}", [
                    'tokens_used' => $result['tokens_used'] ?? 0,
                    'ms' => $responseMs,
                ]);

                return array_merge($result, [
                    'key_tried_count' => $n,
                    'response_time_ms' => $responseMs,
                ]);
            } catch (Exception $e) {
                $msg = Str::limit($e->getMessage(), 150);
                $errors[] = "{$label}: {$msg}";

                if ($keyInfo['pool_key'] instanceof AiApiKey) {
                    try {
                        $keyInfo['pool_key']->recordError($e->getMessage(), $keyInfo['model'] ?? null);
                    } catch (\Throwable $_) { /* best-effort */ }
                }

                $is429 = str_contains($e->getMessage(), '429') || str_contains(strtolower($e->getMessage()), 'rate');
                Log::warning("NongYingAI: key [{$n}/{$total}] {$label} ล้ม", [
                    'error' => $msg,
                    'is_429' => $is429,
                    'remaining' => $total - $n,
                ]);

                // Fast failover on rate-limit, slower on generic errors.
                if ($i < $total - 1) {
                    sleep($is429 ? 1 : 2);
                }
            }
        }

        $errorSummary = implode(' | ', array_slice($errors, 0, 5));
        throw new Exception('ไม่สามารถเชื่อมต่อ AI ได้ (ลองแล้ว ' . count($errors) . ' keys): ' . $errorSummary);
    }

    // ── Key discovery ──────────────────────────────────────────────────

    protected function getAllAvailableKeys(): array
    {
        $keys = [];
        $seen = [];

        foreach (self::PROVIDER_ORDER as $provider) {
            // Query active keys for this provider in priority order.
            $rows = AiApiKey::where('provider', $provider)
                ->where('is_active', 1)
                ->whereNull('deleted_at')
                ->where(function ($q) {
                    $q->whereNull('disabled_until')->orWhere('disabled_until', '<', now());
                })
                ->orderByDesc('priority')
                ->orderBy('consecutive_errors') // prefer healthy keys
                ->get();

            foreach ($rows as $row) {
                if (! $row->api_key || isset($seen[$row->api_key])) continue;
                $seen[$row->api_key] = true;
                $keys[] = [
                    'provider'  => $provider,
                    'api_key'   => $row->api_key,
                    'model'     => $row->metadata['model'] ?? null,
                    'pool_key'  => $row,
                    'source'    => 'pool',
                    'name'      => $row->name,
                ];
            }
        }

        return $keys;
    }

    // ── Provider dispatch ──────────────────────────────────────────────

    protected function callProvider(
        string $provider,
        string $apiKey,
        string $model,
        string $message,
        array $history,
        string $systemPrompt,
        array $options
    ): array {
        return match ($provider) {
            'gemini'     => $this->callGemini($apiKey, $model, $message, $history, $systemPrompt, $options),
            'groq'       => $this->callOpenAiCompatible('https://api.groq.com/openai/v1/chat/completions', $apiKey, $model ?: self::DEFAULT_MODELS['groq'], $message, $history, $systemPrompt, $options, 'groq'),
            'grok'       => $this->callOpenAiCompatible('https://api.x.ai/v1/chat/completions', $apiKey, $model ?: self::DEFAULT_MODELS['grok'], $message, $history, $systemPrompt, $options, 'grok'),
            'qwen'       => $this->callOpenAiCompatible('https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions', $apiKey, $model ?: self::DEFAULT_MODELS['qwen'], $message, $history, $systemPrompt, $options, 'qwen'),
            'openrouter' => $this->callOpenAiCompatible('https://openrouter.ai/api/v1/chat/completions', $apiKey, $model ?: self::DEFAULT_MODELS['openrouter'], $message, $history, $systemPrompt, $options, 'openrouter'),
            'deepseek'   => $this->callOpenAiCompatible('https://api.deepseek.com/v1/chat/completions', $apiKey, $model ?: self::DEFAULT_MODELS['deepseek'], $message, $history, $systemPrompt, $options, 'deepseek'),
            'typhoon'    => $this->callOpenAiCompatible('https://api.opentyphoon.ai/v1/chat/completions', $apiKey, $model ?: self::DEFAULT_MODELS['typhoon'], $message, $history, $systemPrompt, $options, 'typhoon'),
            default      => throw new Exception("Provider '{$provider}' ไม่รองรับใน NongYingAIService"),
        };
    }

    protected function callGemini(string $apiKey, string $model, string $message, array $history, string $systemPrompt, array $options): array
    {
        $model = $model ?: self::DEFAULT_MODELS['gemini'];
        $url = "https://generativelanguage.googleapis.com/v1beta/models/{$model}:generateContent?key={$apiKey}";

        // Gemini format: `systemInstruction` + `contents[]` with `role` + `parts`
        $contents = [];
        foreach ($history as $h) {
            $role = ($h['role'] ?? 'user') === 'assistant' ? 'model' : 'user';
            $contents[] = [
                'role' => $role,
                'parts' => [['text' => $h['content'] ?? '']],
            ];
        }
        $contents[] = [
            'role' => 'user',
            'parts' => [['text' => $message]],
        ];

        $body = [
            'systemInstruction' => ['parts' => [['text' => $systemPrompt]]],
            'contents'          => $contents,
            'generationConfig'  => [
                'temperature'     => $options['temperature'] ?? 0.7,
                'maxOutputTokens' => $options['max_tokens'] ?? 800,
            ],
        ];

        $resp = Http::timeout(30)->post($url, $body);
        if (! $resp->successful()) {
            throw new Exception("Gemini {$resp->status()}: " . Str::limit($resp->body(), 200));
        }
        $json = $resp->json();
        $text = data_get($json, 'candidates.0.content.parts.0.text', '');
        if (! is_string($text) || trim($text) === '') {
            throw new Exception('Gemini returned empty reply');
        }
        $in  = (int) data_get($json, 'usageMetadata.promptTokenCount', 0);
        $out = (int) data_get($json, 'usageMetadata.candidatesTokenCount', 0);

        return [
            'text'          => $text,
            'provider'      => 'gemini',
            'model'         => $model,
            'tokens_used'   => $in + $out,
            'input_tokens'  => $in,
            'output_tokens' => $out,
        ];
    }

    /** OpenAI-compatible chat completion (Groq, Grok, Qwen, OpenRouter,
     *  DeepSeek, Typhoon — they all expose the same shape). */
    protected function callOpenAiCompatible(
        string $url,
        string $apiKey,
        string $model,
        string $message,
        array $history,
        string $systemPrompt,
        array $options,
        string $providerLabel
    ): array {
        $messages = [['role' => 'system', 'content' => $systemPrompt]];
        foreach ($history as $h) {
            $messages[] = [
                'role'    => ($h['role'] ?? 'user') === 'assistant' ? 'assistant' : 'user',
                'content' => $h['content'] ?? '',
            ];
        }
        $messages[] = ['role' => 'user', 'content' => $message];

        $body = [
            'model'       => $model,
            'messages'    => $messages,
            'temperature' => $options['temperature'] ?? 0.7,
            'max_tokens'  => $options['max_tokens'] ?? 800,
        ];

        $headers = ['Authorization' => "Bearer {$apiKey}"];
        if ($providerLabel === 'openrouter') {
            $headers['HTTP-Referer'] = 'https://main.thaiprompt.online';
            $headers['X-Title'] = 'Thaiprompt · Nong Ying';
        }

        $resp = Http::withHeaders($headers)->timeout(30)->post($url, $body);
        if (! $resp->successful()) {
            throw new Exception("{$providerLabel} {$resp->status()}: " . Str::limit($resp->body(), 200));
        }
        $json = $resp->json();
        $text = data_get($json, 'choices.0.message.content', '');
        if (! is_string($text) || trim($text) === '') {
            throw new Exception("{$providerLabel} returned empty reply");
        }
        $in  = (int) data_get($json, 'usage.prompt_tokens', 0);
        $out = (int) data_get($json, 'usage.completion_tokens', 0);

        return [
            'text'          => $text,
            'provider'      => $providerLabel,
            'model'         => $model,
            'tokens_used'   => $in + $out,
            'input_tokens'  => $in,
            'output_tokens' => $out,
        ];
    }
}
