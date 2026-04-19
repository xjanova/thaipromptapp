import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_client.dart';
import '../api/endpoints.dart';

/// Snapshot of `/api/v1/app/config` keyed by `key → Any`.
///
/// Values preserve their backend-declared type (string|int|float|bool|json).
/// Consumers should use the typed accessors rather than reading the map.
@immutable
class RemoteConfig {
  RemoteConfig(this._values, {required this.fetchedAt, this.etag});

  final Map<String, Object?> _values;
  final DateTime fetchedAt;
  final String? etag;

  static RemoteConfig empty() => RemoteConfig(const {}, fetchedAt: DateTime.fromMillisecondsSinceEpoch(0));

  bool has(String key) => _values.containsKey(key);

  String string(String key, {String fallback = ''}) =>
      _values[key]?.toString() ?? fallback;

  int integer(String key, {int fallback = 0}) {
    final v = _values[key];
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

  double number(String key, {double fallback = 0}) {
    final v = _values[key];
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? fallback;
    return fallback;
  }

  bool boolean(String key, {bool fallback = false}) {
    final v = _values[key];
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      return {'1', 'true', 'yes', 'on'}.contains(v.toLowerCase());
    }
    return fallback;
  }

  Map<String, dynamic> jsonObject(String key) {
    final v = _values[key];
    return v is Map<String, dynamic> ? v : const {};
  }
}

/// Fetches + caches remote config with ETag.
class RemoteConfigService {
  RemoteConfigService(this._api, this._prefs);

  final ApiClient _api;
  final SharedPreferences _prefs;

  static const _kBodyCache = 'tp.remote_config.body_json';
  static const _kEtagCache = 'tp.remote_config.etag';
  static const _kFetchedAt = 'tp.remote_config.fetched_at';

  /// Last snapshot from local storage, if any. Null on first launch.
  RemoteConfig? readCached() {
    final raw = _prefs.getString(_kBodyCache);
    if (raw == null) return null;
    try {
      final decoded = (jsonDecode(raw) as Map).cast<String, Object?>();
      return RemoteConfig(
        decoded,
        fetchedAt: DateTime.tryParse(_prefs.getString(_kFetchedAt) ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
        etag: _prefs.getString(_kEtagCache),
      );
    } catch (_) {
      return null;
    }
  }

  /// Fetch from network. On 304 (server supports ETag) or failure, returns
  /// the cached snapshot if we have one.
  Future<RemoteConfig> fetch() async {
    final cached = readCached();
    try {
      final res = await _api.get<Map<String, dynamic>>(
        Api.appConfig,
        // Backend accepts `?etag=` as a query fallback since Dio's If-None-Match
        // handling depends on the interceptor chain. Server returns the prior
        // payload on match (cheap) so we still get correct data if cache empty.
        query: cached?.etag == null ? null : {'etag': cached!.etag},
      );
      final list = (res['data'] as List?) ?? const [];
      final map = <String, Object?>{
        for (final row in list)
          if (row is Map && row['key'] is String) (row['key'] as String): row['value'],
      };
      final snap = RemoteConfig(
        map,
        fetchedAt: DateTime.now(),
        etag: res['etag']?.toString(),
      );
      await _prefs.setString(_kBodyCache, jsonEncode(map));
      if (snap.etag != null) await _prefs.setString(_kEtagCache, snap.etag!);
      await _prefs.setString(_kFetchedAt, snap.fetchedAt.toIso8601String());
      return snap;
    } catch (e) {
      if (cached != null) {
        if (kDebugMode) debugPrint('[RemoteConfig] fetch failed, using cache: $e');
        return cached;
      }
      rethrow;
    }
  }
}

class RemoteConfigController extends AsyncNotifier<RemoteConfig> {
  RemoteConfigService? _service;
  Timer? _timer;

  @override
  Future<RemoteConfig> build() async {
    final api = await ref.watch(apiClientProvider.future);
    final prefs = await SharedPreferences.getInstance();
    _service = RemoteConfigService(api, prefs);
    ref.onDispose(() => _timer?.cancel());

    final cached = _service!.readCached();
    _timer ??= Timer.periodic(const Duration(minutes: 10), (_) => refresh());

    if (cached != null) {
      // Warm-cache first; kick off background refresh.
      Future.microtask(refresh);
      return cached;
    }
    return _service!.fetch();
  }

  /// Force a re-fetch; swallows errors so UI never explodes from a failed poll.
  Future<void> refresh() async {
    final svc = _service;
    if (svc == null) return;
    try {
      state = AsyncData(await svc.fetch());
    } catch (_) {
      // Keep last-known-good.
    }
  }
}

final remoteConfigControllerProvider =
    AsyncNotifierProvider<RemoteConfigController, RemoteConfig>(
  RemoteConfigController.new,
);
