<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

/**
 * Seeds the minimum keys needed for the Thaiprompt Flutter app to stop
 * degrading to cache-only fallbacks.
 *
 * Run with:  php artisan db:seed --class=AppConfigSeeder
 *
 * Safe to run repeatedly — upserts on (key, environment).
 */
class AppConfigSeeder extends Seeder
{
    public function run(): void
    {
        $env = app()->environment();
        $now = now();

        $rows = [
            // -------- Remote config surfaced by lib/core/remote_config --------
            [
                'key'         => 'ai_model_id_gemma4',
                'value'       => 'gemma-4-E4B-it-web.task',
                'value_type'  => 'string',
                'description' => 'MediaPipe model filename for Gemma 4 E4B (tier: high)',
                'is_public'   => true,
            ],
            // HuggingFace LiteRT-compatible .task URLs. These are the
            // models flutter_gemma's `installModel(...).fromNetwork()`
            // can consume directly. Google's Gemma repos are gated —
            // admin must put a valid HF token on the server OR swap to
            // a public mirror if distribution rights allow.
            [
                'key'         => 'ai_model_url_gemma4',
                'value'       => 'https://huggingface.co/google/gemma-3n-E4B-it-litert-preview/resolve/main/gemma-4-E4B-it-web.task',
                'value_type'  => 'string',
                'description' => 'Direct URL for Gemma 4 E4B .task (requires HF token server-side if gated)',
                'is_public'   => true,
            ],
            [
                'key'         => 'ai_model_id_gemma3_4b',
                'value'       => 'gemma-4-E2B-it-web.task',
                'value_type'  => 'string',
                'description' => 'MediaPipe filename for Gemma 3n E2B (tier: mid)',
                'is_public'   => true,
            ],
            [
                'key'         => 'ai_model_url_gemma3_4b',
                'value'       => 'https://huggingface.co/google/gemma-3n-E2B-it-litert-preview/resolve/main/gemma-4-E2B-it-web.task',
                'value_type'  => 'string',
                'description' => 'Direct URL for Gemma 3n E2B .task',
                'is_public'   => true,
            ],
            [
                'key'         => 'ai_model_id_gemma3_1b',
                'value'       => 'gemma-3-1b-it-int4.task',
                'value_type'  => 'string',
                'description' => 'MediaPipe filename for Gemma 3 1B (tier: low)',
                'is_public'   => true,
            ],
            [
                'key'         => 'ai_model_url_gemma3_1b',
                'value'       => 'https://huggingface.co/litert-community/Gemma3-1B-IT/resolve/main/Gemma3-1B-IT_multi-prefill-seq_q4_ekv1280.task',
                'value_type'  => 'string',
                'description' => 'Direct URL for Gemma 3 1B .task (public LiteRT community mirror)',
                'is_public'   => true,
            ],
            [
                'key'         => 'ai_enabled',
                'value'       => '1',
                'value_type'  => 'bool',
                'description' => 'Master switch for the น้องหญิง FAB + chat',
                'is_public'   => true,
            ],

            // Piper voice (empty until admin uploads a voice to CDN)
            [
                'key'         => 'tts_piper_voice_id',
                'value'       => 'th_TH-vaja-medium',
                'value_type'  => 'string',
                'description' => 'Human-readable voice identifier used as filename prefix',
                'is_public'   => true,
            ],
            [
                'key'         => 'tts_piper_model_url',
                'value'       => '',
                'value_type'  => 'string',
                'description' => 'Direct URL to the .onnx VITS model. Fill with CDN URL.',
                'is_public'   => true,
            ],
            [
                'key'         => 'tts_piper_tokens_url',
                'value'       => '',
                'value_type'  => 'string',
                'description' => 'Direct URL to tokens.txt. Fill with CDN URL.',
                'is_public'   => true,
            ],

            // Support phone shown in น้องหญิง fallback dialogs
            [
                'key'         => 'support_phone',
                'value'       => '+66-2-000-0000',
                'value_type'  => 'string',
                'description' => 'Displayed when critical flows need human help',
                'is_public'   => true,
            ],

            // Min/max wallet top-up amounts
            [
                'key'         => 'wallet_topup_min_thb',
                'value'       => '20',
                'value_type'  => 'int',
                'description' => 'Minimum PromptPay top-up amount (THB)',
                'is_public'   => true,
            ],
            [
                'key'         => 'wallet_topup_max_thb',
                'value'       => '50000',
                'value_type'  => 'int',
                'description' => 'Maximum single top-up (THB)',
                'is_public'   => true,
            ],
        ];

        foreach ($rows as $r) {
            DB::table('app_configs')->upsert(
                [
                    'key'         => $r['key'],
                    'environment' => $env,
                    'value'       => $r['value'],
                    'value_type'  => $r['value_type'],
                    'description' => $r['description'],
                    'is_public'   => $r['is_public'],
                    'created_at'  => $now,
                    'updated_at'  => $now,
                ],
                ['key', 'environment'],
                ['value', 'value_type', 'description', 'is_public', 'updated_at']
            );
        }

        $this->command?->info('Seeded ' . count($rows) . " app_configs for environment: $env");
    }
}
