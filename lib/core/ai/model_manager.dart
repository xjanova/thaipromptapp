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

    // Very rough heuristic tuned around Thai-market common devices (2023+).
    // Refine once we have real telemetry post-launch.
    if (sdk >= 34) {
      return ModelTier(
        engine: AiEngineKind.gemma4,
        reason: 'Android $sdk ≥ 34',
      );
    }
    if (sdk >= 31) {
      return ModelTier(
        engine: AiEngineKind.gemma3_4b,
        reason: 'Android $sdk (31-33)',
      );
    }
    if (sdk >= 26) {
      return ModelTier(
        engine: AiEngineKind.gemma3_1b,
        reason: 'Android $sdk (26-30)',
      );
    }
    return ModelTier(
      engine: AiEngineKind.server,
      reason: 'Android $sdk < 26 → server',
    );
  }

  Future<ModelTier> _iosTier() async {
    final info = await _deviceInfo.iosInfo;
    final model = info.utsname.machine;
    // iPhone 14 and above (iPhone15,*+) have plenty of RAM/Neural Engine for
    // Gemma 4 (~4B quantised). Conservative fallback below.
    if (model.startsWith('iPhone15,') ||
        model.startsWith('iPhone16,') ||
        model.startsWith('iPhone17,')) {
      return ModelTier(engine: AiEngineKind.gemma4, reason: 'iPhone $model');
    }
    if (model.startsWith('iPhone13,') || model.startsWith('iPhone14,')) {
      return ModelTier(engine: AiEngineKind.gemma3_4b, reason: 'iPhone $model');
    }
    if (model.startsWith('iPhone11,') || model.startsWith('iPhone12,')) {
      return ModelTier(engine: AiEngineKind.gemma3_1b, reason: 'iPhone $model');
    }
    return ModelTier(engine: AiEngineKind.server, reason: 'iPhone $model → server');
  }
}

final modelManagerProvider = Provider<ModelManager>((_) => ModelManager(DeviceInfoPlugin()));
