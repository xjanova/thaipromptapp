import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../api/api_client.dart';
import '../api/endpoints.dart';
import 'tts_service.dart';

/// High-quality Thai TTS via Gemini 3.1 Native Audio, served through the
/// backend proxy at `POST /v1/ai/tts`.
///
/// Request shape:
///   { "text": "สวัสดีค่ะ", "voice": "th-premwadee", "format": "mp3" }
///
/// Response: audio bytes (Content-Type: audio/mpeg).
/// Backend rate limits per-user (20 req/min is fine for chat use).
class GeminiTtsService implements TtsService {
  GeminiTtsService(this._api);
  final ApiClient _api;
  final AudioPlayer _player = AudioPlayer();
  final _speakingController = StreamController<bool>.broadcast();

  bool _ready = false;
  bool _speaking = false;

  /// Voice + temperature overrides supplied at runtime (from persona).
  /// When null, the server uses its `ai_bot_profiles.tts_config` defaults.
  String? _voice;
  double? _temperature;

  /// Apply admin-configurable voice/temperature from the persona. Safe
  /// to call repeatedly — last value wins.
  void applyConfig({String? voice, double? temperature}) {
    _voice = voice;
    _temperature = temperature;
  }

  @override
  bool get isReady => _ready;

  @override
  bool get isSpeaking => _speaking;

  @override
  Stream<bool> get speakingStream => _speakingController.stream;

  @override
  Future<void> initialize() async {
    _player.playerStateStream.listen((s) {
      final wasSpeaking = _speaking;
      final nowSpeaking = s.playing;
      if (wasSpeaking != nowSpeaking) {
        _speaking = nowSpeaking;
        _speakingController.add(nowSpeaking);
      }
    });
    _ready = true;
  }

  @override
  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    await stop();

    try {
      final resp = await _api.dio.post<List<int>>(
        Api.aiTts,
        data: {
          'text': text,
          'voice': _voice ?? 'th-premwadee',
          if (_temperature != null) 'temperature': _temperature,
          // Server returns WAV regardless of `format` (it wraps Gemini's
          // raw PCM in a RIFF header). Leave the field in the request
          // for backward compatibility with the earlier direct-Gemini
          // proxy; the new pool-backed endpoint ignores it.
          'format': 'wav',
        },
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Accept': 'audio/*'},
        ),
      );
      final bytes = resp.data;
      if (bytes == null || bytes.isEmpty) {
        throw StateError('ไม่ได้รับเสียงตอบกลับ');
      }
      await _player.setAudioSource(_BytesSource(Uint8List.fromList(bytes)));
      await _player.play();
    } catch (e) {
      if (kDebugMode) debugPrint('[GeminiTtsService] speak failed: $e');
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    if (_player.playing) await _player.stop();
  }

  @override
  Future<void> dispose() async {
    await _player.dispose();
    await _speakingController.close();
  }
}

/// Minimal in-memory StreamAudioSource so we can hand MP3 bytes from dio
/// straight to just_audio without writing them to disk.
///
/// `StreamAudioSource` is annotated `@experimental` in just_audio 0.9 even
/// though it's the canonical way to play in-memory audio. Silence the lint.
// ignore_for_file: experimental_member_use
class _BytesSource extends StreamAudioSource {
  _BytesSource(this._bytes);
  final Uint8List _bytes;

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= _bytes.length;
    return StreamAudioResponse(
      sourceLength: _bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(_bytes.sublist(start, end)),
      contentType: 'audio/mpeg',
    );
  }
}

// Silence analyzer — jsonEncode used for future prompts not yet wired.
// ignore: unused_element
String _unused() => jsonEncode({});
