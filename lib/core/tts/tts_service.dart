import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../remote_config/feature_flags.dart';
import 'gemini_tts_service.dart';

/// Text-to-speech for น้องหญิง's voice.
///
/// Engines:
///   • [GeminiTtsService] — online, Gemini 3.1 Native Audio via backend
///     `/v1/ai/tts`. Thai female voice "premwadee". Free-tier covers MVP.
///   • [StubTtsService] — no-op fallback for dev or when TTS is disabled.
///   • Piper/NECTEC (Phase 5.3) — offline engine via sherpa_onnx; same
///     interface so swap is free.
///
/// UI code only holds a [TtsService]; concrete choice lives in the provider.
abstract interface class TtsService {
  Future<void> initialize();
  Future<void> speak(String text);
  Future<void> stop();
  bool get isReady;
  bool get isSpeaking;
  Stream<bool> get speakingStream;
  Future<void> dispose();
}

/// Last-resort fallback — emits "speaking" for a plausible duration so UI
/// feedback stays consistent even when no real engine is connected.
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

/// Resolves the best available engine once and caches it.
///   • `tts_enabled` flag off → Stub
///   • Gemini creation succeeds → Gemini
///   • otherwise → Stub
final ttsServiceProvider = FutureProvider<TtsService>((ref) async {
  final on = ref.watch(flagProvider(FlagKeys.ttsEnabled));
  // In debug we default TTS on; production waits for the remote flag.
  if (!on && !kDebugMode) {
    final stub = StubTtsService();
    ref.onDispose(stub.dispose);
    return stub;
  }

  try {
    final api = await ref.watch(apiClientProvider.future);
    final svc = GeminiTtsService(api);
    await svc.initialize();
    ref.onDispose(svc.dispose);
    return svc;
  } catch (e) {
    if (kDebugMode) debugPrint('[TTS] Gemini init failed, stub fallback: $e');
    final stub = StubTtsService();
    ref.onDispose(stub.dispose);
    return stub;
  }
});
