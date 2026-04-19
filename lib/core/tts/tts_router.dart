import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../api/api_exceptions.dart';
import 'tts_service.dart';

/// Picks the right engine per-utterance.
///
/// Policy:
///   1. Try Gemini (high quality, Thai female voice).
///   2. On quota/auth error (HTTP 429, 403) OR network failure → switch to
///      Piper for this session. All subsequent [speak] calls in the same
///      app process go straight to Piper without re-hitting Gemini — the
///      user doesn't see repeated "cloud" delays while the quota is out.
///   3. If Piper isn't installed either, degrade to the stub.
///   4. Quota flip resets on process restart (so resumption works when
///      Gemini's daily quota resets at midnight UTC).
class TtsRouter implements TtsService {
  TtsRouter({
    required this.primary,
    required this.fallback,
  });

  /// Typically GeminiTtsService.
  final TtsService primary;

  /// Typically PiperTtsService (installed) or StubTtsService (not installed).
  final TtsService fallback;

  bool _quotaExceeded = false;
  final _speakingController = StreamController<bool>.broadcast();
  StreamSubscription<bool>? _primarySub;
  StreamSubscription<bool>? _fallbackSub;
  TtsService get _active => _quotaExceeded ? fallback : primary;

  @override
  bool get isReady => primary.isReady || fallback.isReady;

  @override
  bool get isSpeaking => _active.isSpeaking;

  @override
  Stream<bool> get speakingStream => _speakingController.stream;

  @override
  Future<void> initialize() async {
    await primary.initialize();
    await fallback.initialize();
    _primarySub = primary.speakingStream.listen(_speakingController.add);
    _fallbackSub = fallback.speakingStream.listen(_speakingController.add);
  }

  @override
  Future<void> speak(String text) async {
    if (_quotaExceeded) {
      await fallback.speak(text);
      return;
    }

    try {
      await primary.speak(text);
    } catch (e) {
      if (_isQuotaError(e)) {
        if (kDebugMode) {
          debugPrint('[TtsRouter] quota/auth error on primary ($e) → switching to offline');
        }
        _quotaExceeded = true;
        if (fallback.isReady) {
          await fallback.speak(text);
        }
        return;
      }
      if (_isNetworkError(e)) {
        if (kDebugMode) debugPrint('[TtsRouter] network error → offline once');
        if (fallback.isReady) {
          await fallback.speak(text);
        }
        return;
      }
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    await primary.stop();
    await fallback.stop();
  }

  @override
  Future<void> dispose() async {
    await _primarySub?.cancel();
    await _fallbackSub?.cancel();
    await _speakingController.close();
    await primary.dispose();
    await fallback.dispose();
  }

  bool _isQuotaError(Object e) {
    if (e is DioException) {
      final c = e.response?.statusCode;
      return c == 429 || c == 403;
    }
    return e is RateLimitException || e is ForbiddenException;
  }

  bool _isNetworkError(Object e) =>
      e is NetworkException ||
      e is TimeoutException ||
      (e is DioException &&
          (e.type == DioExceptionType.connectionError ||
              e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout));
}
