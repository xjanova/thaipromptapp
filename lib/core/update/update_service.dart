import 'dart:async';
import 'dart:io' show Platform, File;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../api/api_client.dart';
import '../api/endpoints.dart';
import 'update_info.dart';

/// Possible outcomes of a version check.
sealed class UpdateStatus {
  const UpdateStatus();
}

class UpdateUpToDate extends UpdateStatus {
  const UpdateUpToDate();
}

class UpdateAvailable extends UpdateStatus {
  const UpdateAvailable({required this.info, required this.mandatory});
  final UpdateInfo info;
  final bool mandatory;
}

class UpdateCheckFailed extends UpdateStatus {
  const UpdateCheckFailed(this.message);
  final String message;
}

/// Download progress events emitted by [UpdateService.downloadAndInstall].
class UpdateProgress {
  const UpdateProgress({required this.received, required this.total});
  final int received;
  final int total;

  double get fraction => total == 0 ? 0 : received / total;
  int get percent => (fraction * 100).round();
}

/// Self-update service for Android sideload builds (APK distributed via
/// GitHub Releases).
///
/// Flow:
///   1. [checkForUpdate] calls `/api/v1/app/latest-version` and compares to
///      `package_info_plus.version`.
///   2. If outdated → UI shows [UpdateDialog] with changelog + progress.
///   3. [downloadAndInstall] downloads APK to app docs dir, then opens it —
///      Android shows the system install prompt (user must have granted
///      "install unknown apps" for Thaiprompt).
///
/// iOS: there is no sideload install path — the service only reports status.
/// For iOS distribution we'd use TestFlight / App Store which handles updates
/// natively; skip the download step and show a link instead.
class UpdateService {
  UpdateService(this._api);
  final ApiClient _api;

  /// Convenience for calling [_api.dio.download] with our shared retries off.
  Dio get _dio => _api.dio;

  Future<UpdateStatus> checkForUpdate() async {
    try {
      final res = await _api.get<Map<String, dynamic>>(Api.appLatestVersion);
      final data = (res['data'] is Map<String, dynamic>)
          ? res['data'] as Map<String, dynamic>
          : res;
      final info = UpdateInfo.fromJson(data);
      final pkg = await PackageInfo.fromPlatform();

      final cmp = compareSemver(pkg.version, info.latestVersion);
      if (cmp >= 0) return const UpdateUpToDate();

      final mandatory = compareSemver(pkg.version, info.minSupportedVersion) < 0;
      return UpdateAvailable(info: info, mandatory: mandatory);
    } catch (e) {
      if (kDebugMode) debugPrint('[UpdateService] check failed: $e');
      return UpdateCheckFailed('$e');
    }
  }

  /// Download the APK to the app's docs directory and stream progress.
  /// Android only. On iOS this throws [UnsupportedError].
  Stream<UpdateProgress> downloadAndInstall(UpdateInfo info) async* {
    if (!Platform.isAndroid) {
      throw UnsupportedError('Sideload update is Android-only');
    }

    final controller = StreamController<UpdateProgress>();
    final dir = await getApplicationDocumentsDirectory();
    final filename = 'thaipromptapp-${info.latestVersion}.apk';
    final path = '${dir.path}/$filename';

    // If a previous download partially succeeded, drop it.
    final file = File(path);
    if (await file.exists()) await file.delete();

    unawaited(_runDownload(info.apkUrl, path, controller));

    await for (final p in controller.stream) {
      yield p;
    }

    // Launch installer on completion.
    final result = await OpenFilex.open(path, type: 'application/vnd.android.package-archive');
    if (result.type != ResultType.done) {
      throw StateError('เปิดไฟล์ติดตั้งไม่ได้: ${result.message}');
    }
  }

  Future<void> _runDownload(
    String url,
    String savePath,
    StreamController<UpdateProgress> controller,
  ) async {
    try {
      await _dio.download(
        url,
        savePath,
        options: Options(
          receiveTimeout: const Duration(minutes: 5),
          headers: const {'Accept': 'application/vnd.android.package-archive'},
        ),
        onReceiveProgress: (r, t) {
          controller.add(UpdateProgress(received: r, total: t <= 0 ? 0 : t));
        },
      );
      controller.add(const UpdateProgress(received: 1, total: 1));
    } catch (e) {
      controller.addError(e);
    } finally {
      await controller.close();
    }
  }
}

final updateServiceProvider = FutureProvider<UpdateService>((ref) async {
  final api = await ref.watch(apiClientProvider.future);
  return UpdateService(api);
});

/// Cached result of the latest check — lets Home display a "update available"
/// badge without re-hitting the network.
final updateStatusProvider = FutureProvider<UpdateStatus>((ref) async {
  final svc = await ref.watch(updateServiceProvider.future);
  return svc.checkForUpdate();
});

void unawaited(Future<void> f) {}
