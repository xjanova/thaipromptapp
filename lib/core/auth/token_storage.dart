import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../db/local_db.dart';

const _kToken = 'tp.auth.token';
const _kRefresh = 'tp.auth.refresh';
const _kPinHash = 'tp.wallet.pin_hash';
const _kPinSalt = 'tp.wallet.pin_salt';

/// Persists the Sanctum token + wallet PIN across app launches.
///
/// History: v1.0.0 → v1.0.12 used only `flutter_secure_storage` with
/// `resetOnError: true`. That flag silently wipes the entire keystore
/// on any decryption failure — and on Android 12+ EncryptedSharedPreferences
/// periodically fails with `AEADBadTagException` (known Jetpack bug,
/// triggered by keystore rotations, seamless OS upgrades, or certain
/// ADB install flows). Result: users got logged out after every
/// restart.
///
/// v1.0.13 strategy:
///   1. Write → `KvStore` (SQLite) is the source of truth; additionally
///      mirror to `flutter_secure_storage` for encryption at rest.
///   2. Read → try SQLite first (reliable). Fall back to secure storage
///      if SQLite comes back empty (handles users upgrading from
///      ≤ v1.0.12 who already have a token in secure storage).
///   3. Errors on secure-storage writes are swallowed — losing the
///      mirror is fine; losing the primary isn't, and SQLite is a
///      local file with no keystore dependency.
///   4. `resetOnError` flipped to `false` so we can observe failures
///      in `kDebugMode` instead of silent data loss.
class TokenStorage {
  TokenStorage({required this.secure, required this.kv});

  final FlutterSecureStorage secure;
  final KvStore kv;

  static const _androidOpts = AndroidOptions(
    encryptedSharedPreferences: true,
    resetOnError: false,
  );
  static const _iosOpts = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
    synchronizable: false,
  );

  static FlutterSecureStorage buildSecure() => const FlutterSecureStorage(
        aOptions: _androidOpts,
        iOptions: _iosOpts,
      );

  Future<String?> readToken() => _read(_kToken);
  Future<void> writeToken(String token) => _write(_kToken, token);
  Future<void> deleteToken() => _delete(_kToken);

  Future<String?> readRefresh() => _read(_kRefresh);
  Future<void> writeRefresh(String token) => _write(_kRefresh, token);

  Future<String?> readPinHash() => _read(_kPinHash);
  Future<void> writePinHash(String hash) => _write(_kPinHash, hash);
  Future<void> deletePinHash() => _delete(_kPinHash);

  /// Arbitrary read/write for auxiliary secrets. Keys MUST use `tp.*`.
  Future<String?> readPinHashSalt(String key) => _read(key);
  Future<void> writePinHashSalt(String key, String value) => _write(key, value);

  Future<void> clearAll() async {
    await Future.wait([
      _delete(_kToken),
      _delete(_kRefresh),
      _delete(_kPinHash),
      _delete(_kPinSalt),
    ]);
  }

  // ── internals ──────────────────────────────────────────────────────

  Future<String?> _read(String key) async {
    // 1. SQLite is always present, never corrupts silently.
    final sqliteVal = await kv.read(key);
    if (sqliteVal != null && sqliteVal.isNotEmpty) return sqliteVal;

    // 2. Fallback — users upgrading from ≤ v1.0.12 only have the token
    //    in secure storage. Read it, mirror to SQLite, return.
    try {
      final secureVal = await secure.read(key: key);
      if (secureVal != null && secureVal.isNotEmpty) {
        await kv.write(key, secureVal);
        return secureVal;
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[TokenStorage] secure read failed for $key: $e\n$st');
      }
    }
    return null;
  }

  Future<void> _write(String key, String value) async {
    // Primary: SQLite. Must succeed; let errors propagate.
    await kv.write(key, value);

    // Secondary: secure storage mirror. Best-effort.
    try {
      await secure.write(key: key, value: value);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[TokenStorage] secure mirror write failed for $key: $e\n$st');
      }
    }
  }

  Future<void> _delete(String key) async {
    await kv.delete(key);
    try {
      await secure.delete(key: key);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[TokenStorage] secure delete failed for $key: $e\n$st');
      }
    }
  }
}

final tokenStorageProvider = FutureProvider<TokenStorage>((ref) async {
  final kv = await ref.watch(kvStoreProvider.future);
  return TokenStorage(secure: TokenStorage.buildSecure(), kv: kv);
});
