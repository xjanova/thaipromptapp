<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\NongYingAIService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

/**
 * Text-to-speech proxy for "น้องหญิง".
 *
 * Uses the shared AI pool (same keys that power NongYingAIService::chat
 * and FortuneAIService) to call Gemini 2.5 Flash TTS. Rotates through
 * every Gemini key in the pool on rate limits so a single exhausted
 * key doesn't silence the persona.
 *
 * Female voices only — product rule enforced server-side so a
 * compromised client cannot request a male voice.
 *
 * Request:  POST /api/v1/ai/tts
 *   body:   { "text": "สวัสดีค่ะ", "voice": "th-premwadee", "format": "mp3" }
 * Response: binary audio bytes (Content-Type audio/mpeg) on success,
 *           JSON error on failure.
 */
class AiTtsApiController extends Controller
{
    public function speak(Request $request, NongYingAIService $ai)
    {
        $data = $request->validate([
            'text'   => 'required|string|min:1|max:2000',
            'voice'  => 'nullable|string|max:32',
            'format' => 'nullable|in:mp3,wav,ogg',
        ]);

        try {
            $result = $ai->tts(
                $data['text'],
                $data['voice'] ?? 'th-premwadee',
                $data['format'] ?? 'mp3',
            );

            return response($result['bytes'], 200, [
                'Content-Type'     => $result['mime'],
                'Cache-Control'    => 'private, max-age=300',
                'X-Voice'          => $result['voice'],
                'X-Model'          => $result['model'],
                'X-Provider'       => $result['provider'],
                'X-Keys-Tried'     => (string) $result['key_tried_count'],
                'X-Response-Ms'    => (string) $result['response_time_ms'],
                'X-Thaiprompt-Tts' => 'pool_failover',
            ]);
        } catch (\Throwable $e) {
            Log::error('[AiTts] pool failed', ['error' => $e->getMessage()]);
            return response()->json([
                'error'   => 'tts_unavailable',
                'message' => 'น้องพูดไม่ได้ตอนนี้ค่ะ · ลองใหม่สักครู่นะคะ',
                'detail'  => config('app.debug') ? $e->getMessage() : null,
            ], 503);
        }
    }
}
