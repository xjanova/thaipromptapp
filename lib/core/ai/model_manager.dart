import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ai_engine.dart';

/// Tier-aware selector for which AI engine to use on this device.
///
/// Policy (decided with the user — see ARCHITECTURE.md §5):
///   • RAM ≥ 8 GB + storage ≥ 4 GB → Gemma 4  (primary)
///   • RAM ≥ 6 GB + storage ≥ 3 GB → Gemma 3 4B (fallback)
///   • RAM ≥ 4 GB                  → Gemma 3 1B (fallback)
///   • otherwise                    → server fallback
///
/// Since Flutter has no first-class RAM API we use Android SDK level + device
/// model as a proxy. The choice is cached for the session; in production we
/// also persist it to avoid re-running the benchmark every launch.
class ModelTier {
  const ModelTier({required this.engine, required this.reason});
  final AiEngineKind engine;
  final String reason;

  @override
  String toString() => '$engine ($reason)';
}

class ModelManager {
  ModelManager(this._deviceInfo);
  final DeviceInfoPlugin _deviceInfo;

  ModelTier? _cached;

  Future<ModelTier> selectTier() async {
    final cached = _cached;
    if (cached != null) return cached;

    final tier = await _compute();
    _cached = tier;
    if (kDebugMode) debugPrint('[ModelManager] selected $tier');
    return tier;
  }

  Future<ModelTier> _compute() async {
    try {
      if (Platform.isAndroid) return _androidTier();
      if (Platform.isIOS) return _iosTier();
    } catch (e) {
      if (kDebugMode) debugPrint('[ModelManager] tier probe failed: $e');
    }
    return const ModelTier(
      engine: AiEngineKind.server,
      reason: 'unknown platform → server',
    );
  }

  Future<ModelTier> _androidTier() async {
    final info = await _deviceInfo.androidInfo;
    final sdk = info.version.sdkInt;

    // Gemma 4 E2B is 2 GB on disk, ~3 GB RAM at inference. SDK level is
    // our proxy for RAM/CPU — flagship devices from SDK 34+ (Android 14+)
    // can comfortably run E4B. Mid-range from SDK 29+ (Android 10+) get
    // E2B. Anything older falls back to cloud (server AI pool).
    if (sdk >= 34) {
      return ModelTier(
        engine: AiEngineKind.gemma4_e4b,
        reason: 'Android $sdk ≥ 34 (flagship)',
      );
    }
    if (sdk >= 29) {
      return ModelTier(
        engine: AiEngineKind.gemma4_e2b,
        reason: 'Android $sdk (29-33)',
      );
    }
    return ModelTier(
      engine: AiEngineKind.server,
      reason: 'Android $sdk < 29 → cloud',
    );
  }

  Future<ModelTier> _iosTier() async {
    final info = await _deviceInfo.iosInfo;
    final model = info.utsname.machine;
    // iPhone 15 / 16 / 17 — 8 GB RAM, Neural Engine 35+ TOPS → E4B OK.
    // iPhone 13 / 14 — 6 GB → E2B.
    // Older → cloud. (.task format for iOS is built by MediaPipe iOS too.)
    if (model.startsWith('iPhone15,') ||
        model.startsWith('iPhone16,') ||
        model.startsWith('iPhone17,')) {
      return ModelTier(engine: AiEngineKind.gemma4_e4b, reason: 'iPhone $model');
    }
    if (model.startsWith('iPhone13,') || model.startsWith('iPhone14,')) {
      return ModelTier(engine: AiEngineKind.gemma4_e2b, reason: 'iPhone $model');
    }
    return ModelTier(engine: AiEngineKind.server, reason: 'iPhone $model → cloud');
  }
}

final modelManagerProvider = Provider<ModelManager>((_) => ModelManager(DeviceInfoPlugin()));
