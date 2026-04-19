import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../api/endpoints.dart';

/// Well-known flag keys. Keep in sync with the backend `feature_flags` table.
///
/// Naming: snake_case, feature-scoped. Prefer adding new flags here (typed)
/// over reading strings from [FeatureFlags.enabled].
abstract final class FlagKeys {
  static const aiEnabled = 'ai_enabled';
  static const ttsEnabled = 'tts_enabled';
  static const walletTopupEnabled = 'wallet_topup_enabled';
  static const walletTransferEnabled = 'wallet_transfer_enabled';
  static const affiliateEnabled = 'affiliate_enabled';
  static const newHomeV2 = 'new_home_v2';
  static const forceUpdate = 'force_update';
  static const analyticsEnabled = 'analytics_enabled';
}

@immutable
class FeatureFlags {
  const FeatureFlags(this._map, {required this.fetchedAt});
  final Map<String, bool> _map;
  final DateTime fetchedAt;

  static FeatureFlags empty() =>
      FeatureFlags(const {}, fetchedAt: DateTime.fromMillisecondsSinceEpoch(0));

  bool enabled(String key, {bool fallback = false}) => _map[key] ?? fallback;
}

class FeatureFlagsService {
  FeatureFlagsService(this._api);
  final ApiClient _api;

  Future<FeatureFlags> fetch() async {
    final res = await _api.get<Map<String, dynamic>>(Api.appFlags);
    final raw = res['flags'];
    if (raw is! Map) return FeatureFlags.empty();
    final map = <String, bool>{
      for (final e in raw.entries)
        e.key.toString(): e.value == true || e.value == 1,
    };
    return FeatureFlags(map, fetchedAt: DateTime.now());
  }
}

class FeatureFlagsController extends AsyncNotifier<FeatureFlags> {
  FeatureFlagsService? _service;
  Timer? _timer;

  @override
  Future<FeatureFlags> build() async {
    final api = await ref.watch(apiClientProvider.future);
    _service = FeatureFlagsService(api);
    ref.onDispose(() => _timer?.cancel());
    _timer ??= Timer.periodic(const Duration(minutes: 15), (_) => _refresh());
    try {
      return await _service!.fetch();
    } catch (e) {
      if (kDebugMode) debugPrint('[FeatureFlags] fetch failed: $e');
      return FeatureFlags.empty();
    }
  }

  Future<void> _refresh() async {
    final svc = _service;
    if (svc == null) return;
    try {
      state = AsyncData(await svc.fetch());
    } catch (_) {
      // keep last-known-good
    }
  }
}

final featureFlagsControllerProvider =
    AsyncNotifierProvider<FeatureFlagsController, FeatureFlags>(
  FeatureFlagsController.new,
);

/// Convenience: `ref.watch(flagProvider(FlagKeys.aiEnabled))` → bool
final flagProvider = Provider.autoDispose.family<bool, String>((ref, key) {
  final state = ref.watch(featureFlagsControllerProvider);
  return state.maybeWhen(
    data: (f) => f.enabled(key),
    orElse: () => false,
  );
});
