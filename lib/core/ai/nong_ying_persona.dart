import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../db/local_db.dart';

/// Persona metadata for น้องหญิง — the single source of truth lives on
/// the server (`GET /api/v1/ai/nong-ying/persona`). Admin edits the
/// associated `ai_bot_profiles` row via the admin panel / DB, and the
/// ETag-based cache here picks up the change on the next app launch
/// without a redeploy.
///
/// Local cache: persisted to [KvStore] under `tp.ai.persona`. We also
/// store the ETag so refresh requests can short-circuit with a
/// 304 Not Modified when the server hasn't changed.
///
/// Offline fallback: if we've never reached the server, a minimal
/// hard-coded persona boots the chat until the fetch succeeds. The
/// fallback exists only so the UI has *something* to render during
/// cold-start; it's intentionally terse and not a substitute for the
/// real server-side persona.
class NongYingPersona extends Equatable {
  const NongYingPersona({
    required this.version,
    required this.systemPrompt,
    required this.greeting,
    required this.greetingNotInstalled,
    required this.suggestions,
    required this.temperature,
    required this.topP,
    required this.maxTokens,
    required this.tts,
  });

  /// Server-provided version string (unix timestamp of the bot profile
  /// row's `updated_at`). Changes whenever admin edits the persona.
  final String version;
  final String systemPrompt;
  final String greeting;
  final String greetingNotInstalled;
  final List<String> suggestions;
  final double temperature;
  final double topP;
  final int maxTokens;
  final NongYingTtsConfig tts;

  factory NongYingPersona.fromJson(Map<String, dynamic> j) => NongYingPersona(
        version: (j['version'] ?? '0').toString(),
        systemPrompt: (j['system_prompt'] ?? '').toString(),
        greeting: (j['greeting'] ?? '').toString(),
        greetingNotInstalled: (j['greeting_not_installed'] ?? '').toString(),
        suggestions: (j['suggestions'] as List? ?? const [])
            .map((e) => e.toString())
            .toList(),
        temperature: (j['temperature'] as num? ?? 0.7).toDouble(),
        topP: (j['top_p'] as num? ?? 0.9).toDouble(),
        maxTokens: (j['max_tokens'] as num? ?? 800).toInt(),
        tts: NongYingTtsConfig.fromJson(
            (j['tts'] as Map<String, dynamic>?) ?? const {}),
      );

  Map<String, dynamic> toJson() => {
        'version': version,
        'system_prompt': systemPrompt,
        'greeting': greeting,
        'greeting_not_installed': greetingNotInstalled,
        'suggestions': suggestions,
        'temperature': temperature,
        'top_p': topP,
        'max_tokens': maxTokens,
        'tts': tts.toJson(),
      };

  /// Minimal cold-start fallback. Used only when we've never fetched
  /// the persona and the network is down. Replaced on first success.
  static NongYingPersona fallback() => const NongYingPersona(
        version: 'fallback',
        systemPrompt:
            'คุณคือ "น้องหญิง" ผู้ช่วยของ Thaiprompt (ตลาดชุมชนไทย). '
            'ใช้ "หนู", ลงท้าย "ค่ะ/คะ/นะคะ", ห้ามใช้ "ครับ". '
            'ตอบสั้น 2-3 ประโยค. ใช้ [GO:/path] เมื่อพาไปหน้าในแอพ.',
        greeting:
            'สวัสดีค่ะ 🌸 น้องหญิงเองค่ะ อยากให้น้องช่วยเรื่องอะไรดีคะ?',
        greetingNotInstalled:
            'สวัสดีค่ะ 🌸 น้องหญิงเองค่ะ · ติดตั้งแล้วน้องตอบเร็วขึ้น '
            '[GO:/nong-ying/install]',
        suggestions: [
          'หาผักสดใกล้บ้าน',
          'ออเดอร์ล่าสุดถึงไหน?',
          'Wallet เหลือเท่าไหร่',
          'ทำ affiliate ยังไง',
        ],
        temperature: 0.7,
        topP: 0.9,
        maxTokens: 800,
        tts: NongYingTtsConfig(
          voice: 'th-premwadee',
          voicesAvailable: ['th-premwadee', 'th-achara'],
          temperature: 0.8,
          cloudModel: 'gemini-2.5-flash-preview-tts',
          fallbackEngine: 'piper',
          fallbackVoiceId: 'th_TH-vaja-medium',
          fallbackAutoInstall: false,
        ),
      );

  bool get isFallback => version == 'fallback';

  @override
  List<Object?> get props =>
      [version, systemPrompt, greeting, greetingNotInstalled, suggestions, temperature, topP, maxTokens, tts];
}

class NongYingTtsConfig extends Equatable {
  const NongYingTtsConfig({
    required this.voice,
    required this.voicesAvailable,
    required this.temperature,
    required this.cloudModel,
    required this.fallbackEngine,
    required this.fallbackVoiceId,
    required this.fallbackAutoInstall,
  });

  final String voice;
  final List<String> voicesAvailable;
  final double temperature;
  final String cloudModel;
  final String fallbackEngine;
  final String fallbackVoiceId;
  final bool fallbackAutoInstall;

  factory NongYingTtsConfig.fromJson(Map<String, dynamic> j) {
    final fb = (j['fallback'] as Map<String, dynamic>?) ?? const {};
    return NongYingTtsConfig(
      voice: (j['voice'] ?? 'th-premwadee').toString(),
      voicesAvailable: (j['voices_available'] as List? ?? const [])
          .map((e) => e.toString())
          .toList(),
      temperature: (j['temperature'] as num? ?? 0.8).toDouble(),
      cloudModel: (j['cloud_model'] ?? 'gemini-2.5-flash-preview-tts').toString(),
      fallbackEngine: (fb['engine'] ?? 'piper').toString(),
      fallbackVoiceId: (fb['voice_id'] ?? 'th_TH-vaja-medium').toString(),
      fallbackAutoInstall: fb['auto_install'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'voice': voice,
        'voices_available': voicesAvailable,
        'temperature': temperature,
        'cloud_model': cloudModel,
        'fallback': {
          'engine': fallbackEngine,
          'voice_id': fallbackVoiceId,
          'auto_install': fallbackAutoInstall,
        },
      };

  @override
  List<Object?> get props => [voice, temperature, cloudModel, fallbackEngine, fallbackVoiceId];
}

/// Fetches + caches [NongYingPersona] from the server.
///
/// Cache keys in [KvStore]:
///   • `tp.ai.persona`      → JSON-encoded persona body
///   • `tp.ai.persona_etag` → server ETag for If-None-Match
class NongYingPersonaRepository {
  NongYingPersonaRepository(this._api, this._kv);
  final ApiClient _api;
  final KvStore _kv;

  static const _cacheKey = 'tp.ai.persona';
  static const _etagKey = 'tp.ai.persona_etag';

  /// Load whatever we have cached. Returns [NongYingPersona.fallback]
  /// if there's no cache.
  Future<NongYingPersona> loadCachedOrFallback() async {
    final raw = await _kv.read(_cacheKey);
    if (raw == null || raw.isEmpty) return NongYingPersona.fallback();
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      return NongYingPersona.fromJson(j);
    } catch (_) {
      return NongYingPersona.fallback();
    }
  }

  /// Hit the server. Returns a fresh persona when 200, or the cached
  /// one when 304. On errors falls back to the cached/fallback value.
  Future<NongYingPersona> fetch({bool force = false}) async {
    final cached = await loadCachedOrFallback();
    final etag = force ? null : await _kv.read(_etagKey);

    try {
      final resp = await _api.dio.get<Map<String, dynamic>>(
        '/v1/ai/nong-ying/persona',
        options: Options(
          validateStatus: (s) => s == 200 || s == 304,
          headers: {
            if (etag != null && etag.isNotEmpty) 'If-None-Match': etag,
          },
        ),
      );

      if (resp.statusCode == 304) {
        return cached; // server says cache still valid
      }

      final data = resp.data ?? const <String, dynamic>{};
      final persona = NongYingPersona.fromJson(data);
      await _kv.write(_cacheKey, jsonEncode(persona.toJson()));
      final newEtag = resp.headers.value('etag') ?? resp.headers.value('ETag');
      if (newEtag != null && newEtag.isNotEmpty) {
        await _kv.write(_etagKey, newEtag);
      }
      return persona;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[NongYingPersona] fetch failed: $e\n$st');
      }
      return cached;
    }
  }
}

/// Riverpod provider exposing the current persona.
///
/// Strategy:
///   1. Synchronously emit the cached (or fallback) persona so the
///      chat page can render immediately on cold start.
///   2. Kick off a background fetch to refresh the cache. If it returns
///      a different version, the provider state updates and consumers
///      rebuild.
class NongYingPersonaController extends AsyncNotifier<NongYingPersona> {
  NongYingPersonaRepository? _repo;

  @override
  Future<NongYingPersona> build() async {
    final api = await ref.watch(apiClientProvider.future);
    final kv = await ref.watch(kvStoreProvider.future);
    _repo = NongYingPersonaRepository(api, kv);

    final cached = await _repo!.loadCachedOrFallback();
    // Refresh in the background so the first render isn't blocked by
    // the network. Update state once the fresh copy arrives.
    unawaited(_refreshInBackground());
    return cached;
  }

  Future<void> _refreshInBackground() async {
    try {
      final fresh = await _repo!.fetch();
      if (state.valueOrNull?.version != fresh.version) {
        state = AsyncData(fresh);
      }
    } catch (_) {/* non-fatal */}
  }

  /// Force a re-fetch (e.g. user pulls-to-refresh).
  Future<void> refresh() async {
    if (_repo == null) return;
    final fresh = await _repo!.fetch(force: true);
    state = AsyncData(fresh);
  }
}

final nongYingPersonaProvider =
    AsyncNotifierProvider<NongYingPersonaController, NongYingPersona>(
  NongYingPersonaController.new,
);
