import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../api/api_client.dart';
import '../api/endpoints.dart';
import 'location_service.dart';

/// A buffered, consent-aware analytics client.
///
/// Design:
///   • All events go into an in-memory ring buffer + a persisted JSON list in
///     SharedPreferences so we survive process death.
///   • Flush triggers:
///       - buffer reaches `batchSize`
///       - `flushInterval` elapses
///       - app backgrounded (via [bindAppLifecycle])
///       - manual [flush]
///   • Respect consent — when off, [track] is a no-op and we clear any pending
///     queue so we don't accidentally upload later.
///   • GPS precision is clamped to geohash-5 (~5km) unless the event explicitly
///     requests higher precision (delivery tracking).
class EventTracker {
  EventTracker._({
    required this.api,
    required this.prefs,
    required this.deviceInfo,
    required this.packageInfo,
    required this.location,
    this.batchSize = 50,
    this.flushInterval = const Duration(seconds: 30),
  }) {
    _restorePending();
    _timer = Timer.periodic(flushInterval, (_) => flush());
  }

  static Future<EventTracker> create(
    ApiClient api,
    LocationService loc, {
    int batchSize = 50,
    Duration flushInterval = const Duration(seconds: 30),
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final pkg = await PackageInfo.fromPlatform();
    final di = DeviceInfoPlugin();
    return EventTracker._(
      api: api,
      prefs: prefs,
      deviceInfo: di,
      packageInfo: pkg,
      location: loc,
      batchSize: batchSize,
      flushInterval: flushInterval,
    );
  }

  final ApiClient api;
  final SharedPreferences prefs;
  final DeviceInfoPlugin deviceInfo;
  final PackageInfo packageInfo;
  final LocationService location;
  final int batchSize;
  final Duration flushInterval;

  // Session
  final _sessionId = const Uuid().v4();
  final DateTime _sessionStartedAt = DateTime.now();

  // Queue
  final List<Map<String, dynamic>> _queue = [];
  Timer? _timer;
  String? _cachedDeviceTier; // low|mid|high
  String? _cachedStartGeohash;
  bool _flushing = false;
  static const _kQueueKey = 'tp.analytics.queue_json';
  static const _kConsentKey = 'tp.analytics.consent';

  // ---------- Consent ----------
  bool get consented => prefs.getBool(_kConsentKey) ?? false;
  Future<void> setConsent(bool on) async {
    await prefs.setBool(_kConsentKey, on);
    if (!on) {
      _queue.clear();
      await prefs.remove(_kQueueKey);
    }
  }

  // ---------- Lifecycle binding ----------
  void bindAppLifecycle() {
    WidgetsBinding.instance.addObserver(_LifecycleHook(onBackground: flush));
  }

  // ---------- Tracking ----------
  Future<void> track(
    String name, {
    Map<String, dynamic>? props,
    int geohashPrecision = GeohashPrecision.analytics,
  }) async {
    if (!consented) return;

    String? geohash;
    if (geohashPrecision > 0) {
      final fix = await location.currentFix(precision: geohashPrecision);
      if (!fix.isEmpty) geohash = fix.geohash;
    }

    final event = <String, dynamic>{
      'name': name,
      'ts': DateTime.now().toUtc().toIso8601String(),
      if (props != null && props.isNotEmpty) 'props': props,
      if (geohash != null) 'geohash': geohash,
    };

    _queue.add(event);
    await _persistQueue();

    if (_queue.length >= batchSize) {
      unawaited(flush());
    }
  }

  /// Convenience for screen views — emitted from the router's observer or
  /// directly from a widget's `initState`.
  Future<void> screenView(String route, {Map<String, dynamic>? props}) =>
      track('screen_view', props: {'route': route, ...?props});

  // ---------- Flush ----------
  Future<void> flush() async {
    if (_flushing || !consented || _queue.isEmpty) return;
    _flushing = true;
    final batch = List<Map<String, dynamic>>.from(_queue);

    try {
      final session = await _sessionEnvelope();
      await api.post<Map<String, dynamic>>(
        Api.eventsBatch,
        data: {
          'session': session,
          'events': batch,
        },
      );
      _queue.removeRange(0, batch.length);
      await _persistQueue();
    } catch (e) {
      if (kDebugMode) debugPrint('[EventTracker] flush failed: $e · keeping ${batch.length} events');
      // On failure, leave the batch in the queue; next tick will retry.
    } finally {
      _flushing = false;
    }
  }

  Future<Map<String, dynamic>> _sessionEnvelope() async {
    _cachedDeviceTier ??= await _resolveDeviceTier();
    _cachedStartGeohash ??=
        (await location.currentFix(precision: GeohashPrecision.analytics)).geohash;

    return {
      'id': _sessionId,
      'started_at': _sessionStartedAt.toUtc().toIso8601String(),
      'app_version': '${packageInfo.version}+${packageInfo.buildNumber}',
      'device_platform': Platform.isIOS ? 'ios' : 'android',
      'device_tier': _cachedDeviceTier,
      if (_cachedStartGeohash != null && _cachedStartGeohash!.isNotEmpty)
        'start_geohash': _cachedStartGeohash,
    };
  }

  /// Classify the device into low/mid/high for AI model-selection decisions.
  /// Stored in `device_tier` on every session envelope.
  Future<String> _resolveDeviceTier() async {
    try {
      if (Platform.isAndroid) {
        final info = await deviceInfo.androidInfo;
        // SDK + total-RAM heuristic. Android doesn't expose RAM without
        // reflection; use SDK + manufacturer as proxy.
        final sdk = info.version.sdkInt;
        if (sdk >= 33) return 'high';
        if (sdk >= 28) return 'mid';
        return 'low';
      }
      if (Platform.isIOS) {
        final info = await deviceInfo.iosInfo;
        final model = info.utsname.machine;
        // iPhone 12+ (iPhone13,*) or newer considered high.
        if (model.startsWith('iPhone13,') ||
            model.startsWith('iPhone14,') ||
            model.startsWith('iPhone15,') ||
            model.startsWith('iPhone16,')) {
          return 'high';
        }
        if (model.startsWith('iPhone11,') || model.startsWith('iPhone12,')) {
          return 'mid';
        }
        return 'low';
      }
    } catch (_) {}
    return 'mid';
  }

  // ---------- Persistence ----------
  Future<void> _persistQueue() async {
    if (_queue.isEmpty) {
      await prefs.remove(_kQueueKey);
      return;
    }
    await prefs.setString(_kQueueKey, jsonEncode(_queue));
  }

  void _restorePending() {
    final raw = prefs.getString(_kQueueKey);
    if (raw == null) return;
    try {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      _queue.addAll(list);
    } catch (_) {
      // corrupt cache → drop silently
    }
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
    unawaited(flush());
  }
}

/// Observes backgrounding so we can flush before the OS kills us.
class _LifecycleHook extends WidgetsBindingObserver {
  _LifecycleHook({required this.onBackground});
  final Future<void> Function() onBackground;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      unawaited(onBackground());
    }
  }
}

// Riverpod wiring ---------------------------------------------------------

final eventTrackerProvider = FutureProvider<EventTracker>((ref) async {
  final api = await ref.watch(apiClientProvider.future);
  final loc = ref.watch(locationServiceProvider);
  final tracker = await EventTracker.create(api, loc);
  ref.onDispose(tracker.dispose);
  return tracker;
});

void unawaited(Future<void> f) {}
