import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Text-to-Speech surface for น้องหญิง voice output.
///
/// Target engine: Piper (via sherpa-onnx-flutter), offline, voice
/// `th_TH-vaja-medium` (NECTEC) — bundled in `assets/tts/` (~60 MB).
/// See ARCHITECTURE.md §6.
///
/// This file intentionally ships as a stub so we can compile and ship the
/// current release. [speak] is a no-op today; it will light up once the native
/// binding is added (tracked as Phase 5.2).
///
/// Keep the public surface minimal — UI code must not care which engine is
/// behind. Swap implementations by passing a different concrete class to the
/// Riverpod provider override in tests.
abstract interface class TtsService {
  Future<void> initialize();
  Future<void> speak(String text);
  Future<void> stop();
  bool get isReady;
  bool get isSpeaking;
  Stream<bool> get speakingStream;
}

/// Stub implementation — no audio output, but API-compatible.
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
    if (kDebugMode) debugPrint('[TTS stub] would speak: ${text.substring(0, text.length > 40 ? 40 : text.length)}...');
    _speaking = true;
    _speakingController.add(true);
    // Pretend the voice takes ~200ms per 10 chars.
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
}

final ttsServiceProvider = Provider<TtsService>((ref) {
  final svc = StubTtsService();
  // initialize() is sync-safe for the stub; real engines will do it in
  // .create() and wrap the whole thing in a FutureProvider.
  svc.initialize();
  return svc;
});
