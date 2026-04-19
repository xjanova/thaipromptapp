import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// Geohash precision levels we use:
///   - precision 5 (≈4.9km × 4.9km) — safe for analytics (home, browse, etc.)
///   - precision 7 (≈153m × 153m) — only used for live-order delivery
///     tracking, and only while an order is in flight.
class GeohashPrecision {
  const GeohashPrecision._();
  static const analytics = 5;
  static const delivery = 7;
}

/// Result of a fix: either a coordinate (with geohash) or a reason we
/// couldn't/shouldn't grab one (permission denied, services off, consent off).
class LocationFix {
  const LocationFix({
    required this.geohash,
    required this.precision,
    this.lat,
    this.lng,
    this.sourceAccuracy,
  });
  final String geohash;
  final int precision;
  final double? lat;
  final double? lng;
  final double? sourceAccuracy;

  static const denied = LocationFix(geohash: '', precision: 0);
  bool get isEmpty => geohash.isEmpty;
}

class LocationService {
  LocationService();

  /// Get the current location, hashed to the requested precision.
  /// Returns [LocationFix.denied] when we cannot or should not fetch (denied,
  /// services off). Never throws on permission problems — caller can treat
  /// the "denied" sentinel as "don't attach geo to events".
  Future<LocationFix> currentFix({int precision = GeohashPrecision.analytics}) async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return LocationFix.denied;

      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return LocationFix.denied;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 5),
        ),
      );
      return LocationFix(
        geohash: Geohash.encode(pos.latitude, pos.longitude, precision: precision),
        precision: precision,
        lat: pos.latitude,
        lng: pos.longitude,
        sourceAccuracy: pos.accuracy,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[LocationService] fix failed: $e');
      return LocationFix.denied;
    }
  }
}

final locationServiceProvider = Provider<LocationService>((_) => LocationService());

// ---------------------------------------------------------------------------
// Geohash — minimal encoder (base32, no deps).
// Based on the standard geohash algorithm by Gustavo Niemeyer.
// ---------------------------------------------------------------------------

class Geohash {
  const Geohash._();

  static const _base32 = '0123456789bcdefghjkmnpqrstuvwxyz';

  static String encode(double lat, double lng, {int precision = 5}) {
    assert(precision > 0 && precision <= 12);
    var latLo = -90.0, latHi = 90.0;
    var lngLo = -180.0, lngHi = 180.0;

    final out = StringBuffer();
    var bits = 0;
    var bit = 0;
    var even = true;

    while (out.length < precision) {
      if (even) {
        final mid = (lngLo + lngHi) / 2;
        if (lng >= mid) {
          bits = (bits << 1) | 1;
          lngLo = mid;
        } else {
          bits = bits << 1;
          lngHi = mid;
        }
      } else {
        final mid = (latLo + latHi) / 2;
        if (lat >= mid) {
          bits = (bits << 1) | 1;
          latLo = mid;
        } else {
          bits = bits << 1;
          latHi = mid;
        }
      }
      even = !even;
      bit++;
      if (bit == 5) {
        out.write(_base32[bits]);
        bits = 0;
        bit = 0;
      }
    }
    return out.toString();
  }

  /// Given a geohash, return its bounding-box midpoint (useful for re-hashing).
  static ({double lat, double lng}) decode(String hash) {
    var latLo = -90.0, latHi = 90.0;
    var lngLo = -180.0, lngHi = 180.0;
    var even = true;
    for (final c in hash.split('')) {
      final idx = _base32.indexOf(c);
      if (idx < 0) throw ArgumentError('invalid geohash char: $c');
      for (var b = 4; b >= 0; b--) {
        final bit = (idx >> b) & 1;
        if (even) {
          final mid = (lngLo + lngHi) / 2;
          if (bit == 1) {
            lngLo = mid;
          } else {
            lngHi = mid;
          }
        } else {
          final mid = (latLo + latHi) / 2;
          if (bit == 1) {
            latLo = mid;
          } else {
            latHi = mid;
          }
        }
        even = !even;
      }
    }
    return (lat: (latLo + latHi) / 2, lng: (lngLo + lngHi) / 2);
  }

  /// Great-circle distance in metres between two geohashes (for debugging
  /// privacy claims like "precision 5 ≈ 5km").
  static double distanceMetres(String a, String b) {
    final pa = decode(a);
    final pb = decode(b);
    const r = 6371e3;
    final dLat = _rad(pb.lat - pa.lat);
    final dLng = _rad(pb.lng - pa.lng);
    final s = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(pa.lat)) *
            math.cos(_rad(pb.lat)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return 2 * r * math.atan2(math.sqrt(s), math.sqrt(1 - s));
  }

  static double _rad(double d) => d * math.pi / 180;
}
