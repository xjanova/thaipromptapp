import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ai/nong_ying_persona.dart';
import '../api/api_client.dart';
import '../remote_config/feature_flags.dart';
import '../remote_config/remote_config.dart';
import 'gemini_tts_service.dart';
import 'piper_tts_service.dart';
import 'piper_voice_manager.dart';
import 'tts_router.dart';

/// Text-to-speech for น้องหญิง's voice.
///
/// Policy (set by the user, enforced in code):
///   • Chat replies do NOT auto-speak. The UI only calls [speak] when the
///     user taps "ฟังเสียง" on a specific bubble.
///   • Primary engine: Gemini 3.1 Native Audio via backend `/v1/ai/tts`.
///   • When Gemini returns 429/403 (quota/auth), router auto-falls back to
///     Piper on-device for the rest of the session.
///   • Piper voice assets are downloaded explicitly from Settings (never
///     bundled in the APK). If Piper isn't installed the fallback is a stub.
///   • All voices are female · male voices are removed.
abstract interface class TtsService {
  Future<void> initialize();
  Future<void> speak(String text);
  Future<void> stop();
  bool get isReady;
  bool get isSpeaking;
  Stream<bool> get speakingStream;
  Future<void> dispose();
}

/// API-compatible no-op. Used when TTS is disabled by flag or Gemini init
/// fails AND Piper isn't installed yet.
class StubTtsService implements TtsService {
  final _speakingController = StreamController<bool>.broadcast();
  bool _speaking = false;

  @override
  bool get isReady => true;

  @override
  bool get isSpeaking => _speaking;

  @override
  Stream<bool> get speakingStream => _speakingController.stream;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> speak(String text) async {
    if (kDebugMode) {
      debugPrint('[TTS stub] would speak: '
          '${text.substring(0, text.length > 40 ? 40 : text.length)}...');
    }
    _speaking = true;
    _speakingController.add(true);
    final ms = 200 + text.length * 20;
    await Future<void>.delayed(Duration(milliseconds: ms.clamp(200, 5000)));
    _speaking = false;
    _speakingController.add(false);
  }

  @override
  Future<void> stop() async {
    if (!_speaking) return;
    _speaking = false;
    _speakingController.add(false);
  }

  @override
  Future<void> dispose() async {
    await _speakingController.close();
  }
}

/// Build the composite engine:
///   • TtsRouter( primary = Gemini , fallback = Piper-or-Stub )
///
/// The router handles the quota-exceeded flip transparently.
final ttsServiceProvider = FutureProvider<TtsService>((ref) async {
  final on = ref.watch(flagProvider(FlagKeys.ttsEnabled));
  // Dev builds default TTS on; production waits for the `tts_enabled` flag.
  if (!on && !kDebugMode) {
    final stub = StubTtsService();
    ref.onDispose(stub.dispose);
    return stub;
  }

  final api = await ref.watch(apiClientProvider.future);
  final rc = ref.watch(remoteConfigControllerProvider).valueOrNull ?? RemoteConfig.empty();

  final primary = GeminiTtsService(api);
  // Apply persona-level TTS config (voice, temperature) so admin edits
  // to `ai_bot_profiles.tts_config` take effect without an APK update.
  // We watch the provider so subsequent persona refreshes re-apply.
  ref.listen(nongYingPersonaProvider, (_, next) {
    final p = next.valueOrNull;
    if (p == null) return;
    primary.applyConfig(voice: p.tts.voice, temperature: p.tts.temperature);
  });
  // Seed with whatever the provider has right now (may be cache or
  // fallback — both populate the voice + temperature).
  final initialPersona = ref.read(nongYingPersonaProvider).valueOrNull;
  if (initialPersona != null) {
    primary.applyConfig(
      voice: initialPersona.tts.voice,
      temperature: initialPersona.tts.temperature,
    );
  }

  TtsService fallback;
  try {
    final manager = PiperVoiceManager(rc: rc, api: api);
    fallback = PiperTtsService(manager: manager);
    // initialize() will no-op when the voice isn't installed yet.
  } catch (e) {
    if (kDebugMode) debugPrint('[TTS] Piper unavailable, stub fallback: $e');
    fallback = StubTtsService();
  }

  final router = TtsRouter(primary: primary, fallback: fallback);
  await router.initialize();
  ref.onDispose(router.dispose);
  return router;
});
