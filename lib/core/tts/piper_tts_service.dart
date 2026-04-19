import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

import 'piper_voice_manager.dart';
import 'tts_service.dart';

/// Offline Piper (VITS) TTS via sherpa-onnx.
///
/// Voice files are downloaded by [PiperVoiceManager] (never bundled in APK).
/// This service:
///   1. Reads the installed voice bundle.
///   2. Builds an `OfflineTts` with vits sub-config.
///   3. On [speak] synthesizes WAV samples to a temp file and plays with
///      just_audio.
///
/// Used as a **free-forever fallback** when the Gemini cloud TTS returns
/// quota errors (429/403) or the user is offline.
class PiperTtsService implements TtsService {
  PiperTtsService({required this.manager});
  final PiperVoiceManager manager;

  sherpa.OfflineTts? _tts;
  final AudioPlayer _player = AudioPlayer();
  final _speakingController = StreamController<bool>.broadcast();
  bool _speaking = false;

  @override
  bool get isReady => _tts != null;

  @override
  bool get isSpeaking => _speaking;

  @override
  Stream<bool> get speakingStream => _speakingController.stream;

  @override
  Future<void> initialize() async {
    final bundle = await manager.readInstalled();
    if (bundle == null) {
      // Voice not yet downloaded — Settings shows an install card.
      return;
    }
    try {
      sherpa.initBindings();
      final vits = sherpa.OfflineTtsVitsModelConfig(
        model: bundle.modelPath,
        tokens: bundle.tokensPath,
        lexicon: bundle.lexiconPath,
        dataDir: bundle.dataDir,
        noiseScale: 0.667,
        noiseScaleW: 0.8,
        lengthScale: 1.0,
      );
      final modelCfg = sherpa.OfflineTtsModelConfig(
        vits: vits,
        numThreads: 2,
        debug: false,
        provider: 'cpu',
      );
      final cfg = sherpa.OfflineTtsConfig(model: modelCfg);
      _tts = sherpa.OfflineTts(cfg);

      _player.playerStateStream.listen((s) {
        final was = _speaking;
        final now = s.playing;
        if (was != now) {
          _speaking = now;
          _speakingController.add(now);
        }
      });
    } catch (e) {
      if (kDebugMode) debugPrint('[PiperTtsService] init failed: $e');
      _tts = null;
    }
  }

  @override
  Future<void> speak(String text) async {
    final tts = _tts;
    if (tts == null) throw StateError('Piper voice ยังไม่ได้ติดตั้ง');
    if (text.trim().isEmpty) return;

    await stop();

    final audio = tts.generate(text: text, sid: 0, speed: 1.0);
    final wav = _encodeWav(audio.samples, audio.sampleRate);

    final tmp = await getTemporaryDirectory();
    final out = File('${tmp.path}/piper-reply.wav');
    await out.writeAsBytes(wav, flush: true);

    await _player.setFilePath(out.path);
    await _player.play();
  }

  @override
  Future<void> stop() async {
    if (_player.playing) await _player.stop();
  }

  @override
  Future<void> dispose() async {
    _tts?.free();
    _tts = null;
    await _player.dispose();
    await _speakingController.close();
  }

  /// Encode Float32 PCM samples into a 16-bit mono WAV byte buffer that
  /// just_audio can play directly.
  Uint8List _encodeWav(List<double> samples, int sampleRate) {
    final bytesPerSample = 2;
    final numChannels = 1;
    final dataSize = samples.length * bytesPerSample;

    final buffer = BytesBuilder();
    // RIFF header
    buffer.add(_asciiBytes('RIFF'));
    buffer.add(_u32(36 + dataSize));
    buffer.add(_asciiBytes('WAVE'));
    // fmt chunk
    buffer.add(_asciiBytes('fmt '));
    buffer.add(_u32(16)); // chunk size
    buffer.add(_u16(1)); // PCM
    buffer.add(_u16(numChannels));
    buffer.add(_u32(sampleRate));
    buffer.add(_u32(sampleRate * numChannels * bytesPerSample));
    buffer.add(_u16(numChannels * bytesPerSample));
    buffer.add(_u16(bytesPerSample * 8));
    // data chunk
    buffer.add(_asciiBytes('data'));
    buffer.add(_u32(dataSize));
    for (final s in samples) {
      final clamped = s.clamp(-1.0, 1.0);
      final i16 = (clamped * 32767).round();
      buffer.add(_u16(i16 < 0 ? i16 + 0x10000 : i16));
    }
    return buffer.toBytes();
  }

  List<int> _asciiBytes(String s) => s.codeUnits;
  List<int> _u16(int v) => [v & 0xff, (v >> 8) & 0xff];
  List<int> _u32(int v) => [
        v & 0xff,
        (v >> 8) & 0xff,
        (v >> 16) & 0xff,
        (v >> 24) & 0xff,
      ];
}
