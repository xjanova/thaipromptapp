import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../api/api_client.dart';
import '../remote_config/remote_config.dart';

/// Local on-device location of a downloaded Piper voice.
class PiperVoiceBundle {
  const PiperVoiceBundle({
    required this.voiceId,
    required this.modelPath,
    required this.tokensPath,
    this.dataDir = '',
    this.lexiconPath = '',
  });
  final String voiceId;
  final String modelPath;
  final String tokensPath;
  final String dataDir;
  final String lexiconPath;

  bool get isInstalled =>
      File(modelPath).existsSync() && File(tokensPath).existsSync();
}

/// Progress tick for voice downloads.
class PiperInstallProgress {
  const PiperInstallProgress({
    required this.received,
    required this.total,
    required this.currentFile,
  });
  final int received;
  final int total;
  final String currentFile;
  double get fraction => total == 0 ? 0 : received / total;
  int get percent => (fraction * 100).round();
}

/// Downloads Piper voice assets (VITS ONNX + tokens + optional lexicon)
/// into the app's documents dir. Voice files are NEVER bundled with the APK
/// — they live behind remote-config URLs so the admin can swap voices or
/// hotpatch without a client release.
///
/// Expected remote-config keys (string):
///   • `tts_piper_voice_id`              · e.g. "th_TH-vaja-medium"
///   • `tts_piper_model_url`             · *.onnx
///   • `tts_piper_tokens_url`            · tokens.txt
///   • `tts_piper_lexicon_url` (optional) · lexicon.txt
///   • `tts_piper_data_dir_tarball` (optional) · tar file with espeak-ng data
class PiperVoiceManager {
  PiperVoiceManager({required this.rc, required this.api});
  final RemoteConfig rc;
  final ApiClient api;

  Future<Directory> _voiceDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/tts/piper');
    if (!dir.existsSync()) await dir.create(recursive: true);
    return dir;
  }

  String get voiceId => rc.string('tts_piper_voice_id', fallback: 'th_TH-vaja-medium');

  Future<PiperVoiceBundle?> readInstalled() async {
    final vid = voiceId;
    final dir = await _voiceDir();
    final bundle = PiperVoiceBundle(
      voiceId: vid,
      modelPath: '${dir.path}/$vid.onnx',
      tokensPath: '${dir.path}/$vid.tokens.txt',
      lexiconPath: '${dir.path}/$vid.lexicon.txt',
      dataDir: '${dir.path}/$vid.data',
    );
    return bundle.isInstalled ? bundle : null;
  }

  /// Download whichever files are advertised by remote config.
  /// Streams [PiperInstallProgress] — one tick per byte chunk across all
  /// files combined.
  Stream<PiperInstallProgress> install() async* {
    final modelUrl = rc.string('tts_piper_model_url');
    final tokensUrl = rc.string('tts_piper_tokens_url');
    if (modelUrl.isEmpty || tokensUrl.isEmpty) {
      throw StateError('ยังไม่ได้ตั้งค่าแหล่งดาวน์โหลด Piper voice');
    }
    final lexiconUrl = rc.string('tts_piper_lexicon_url');

    final dir = await _voiceDir();
    final vid = voiceId;

    final files = <_VoiceFile>[
      _VoiceFile(url: modelUrl, path: '${dir.path}/$vid.onnx', label: 'model.onnx'),
      _VoiceFile(url: tokensUrl, path: '${dir.path}/$vid.tokens.txt', label: 'tokens.txt'),
      if (lexiconUrl.isNotEmpty)
        _VoiceFile(url: lexiconUrl, path: '${dir.path}/$vid.lexicon.txt', label: 'lexicon.txt'),
    ];

    // Discover total size up front so the bar shows a real percentage.
    var grandTotal = 0;
    for (final f in files) {
      try {
        final head = await api.dio.head<void>(f.url);
        final len = head.headers.value(Headers.contentLengthHeader);
        if (len != null) grandTotal += int.tryParse(len) ?? 0;
      } catch (_) {
        // Size probing is best-effort; progress bar will show a spinner.
      }
    }

    var receivedAcrossFiles = 0;
    for (final f in files) {
      final controller = StreamController<int>();
      unawaited(api.dio.download(
        f.url,
        f.path,
        options: Options(receiveTimeout: const Duration(minutes: 10)),
        onReceiveProgress: (r, _) => controller.add(r),
      ).then((_) => controller.close(), onError: (Object e) {
        controller.addError(e);
        controller.close();
      }));

      var lastReceived = 0;
      await for (final n in controller.stream) {
        final delta = n - lastReceived;
        lastReceived = n;
        receivedAcrossFiles += delta;
        yield PiperInstallProgress(
          received: receivedAcrossFiles,
          total: grandTotal == 0 ? receivedAcrossFiles * 2 : grandTotal,
          currentFile: f.label,
        );
      }
    }

    yield PiperInstallProgress(
      received: receivedAcrossFiles,
      total: grandTotal == 0 ? receivedAcrossFiles : grandTotal,
      currentFile: 'done',
    );
  }

  Future<void> uninstall() async {
    final dir = await _voiceDir();
    if (dir.existsSync()) await dir.delete(recursive: true);
  }
}

class _VoiceFile {
  _VoiceFile({required this.url, required this.path, required this.label});
  final String url;
  final String path;
  final String label;
}

final piperVoiceManagerProvider = Provider<PiperVoiceManager>((ref) {
  final api = ref.watch(apiClientProvider).maybeWhen(
        data: (v) => v,
        orElse: () => null,
      );
  final rc = ref.watch(remoteConfigControllerProvider).valueOrNull ?? RemoteConfig.empty();
  if (api == null) {
    throw StateError('ApiClient not ready yet');
  }
  return PiperVoiceManager(rc: rc, api: api);
});

void unawaited(Future<void> f) {}
