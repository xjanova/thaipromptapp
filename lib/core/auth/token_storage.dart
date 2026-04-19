import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _kToken = 'tp.auth.token';
const _kRefresh = 'tp.auth.refresh';
const _kPinHash = 'tp.wallet.pin_hash';

/// Secure wrapper around [FlutterSecureStorage] for Sanctum token + wallet PIN.
///
/// All writes go through here — NEVER call FlutterSecureStorage directly from
/// feature code. Keys are single source of truth.
class TokenStorage {
  TokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const _androidOpts = AndroidOptions(
    encryptedSharedPreferences: true,
    resetOnError: true,
  );
  static const _iosOpts = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
    synchronizable: false,
  );

  static TokenStorage create() => TokenStorage(
        const FlutterSecureStorage(aOptions: _androidOpts, iOptions: _iosOpts),
      );

  Future<String?> readToken() => _storage.read(key: _kToken);
  Future<void> writeToken(String token) => _storage.write(key: _kToken, value: token);
  Future<void> deleteToken() => _storage.delete(key: _kToken);

  Future<String?> readRefresh() => _storage.read(key: _kRefresh);
  Future<void> writeRefresh(String token) =>
      _storage.write(key: _kRefresh, value: token);

  Future<String?> readPinHash() => _storage.read(key: _kPinHash);
  Future<void> writePinHash(String hash) =>
      _storage.write(key: _kPinHash, value: hash);
  Future<void> deletePinHash() => _storage.delete(key: _kPinHash);

  /// Arbitrary read/write for auxiliary secrets (e.g. PIN salt).
  /// Keys MUST use the `tp.*` namespace; callers are responsible for picking
  /// non-colliding keys.
  Future<String?> readPinHashSalt(String key) => _storage.read(key: key);
  Future<void> writePinHashSalt(String key, String value) =>
      _storage.write(key: key, value: value);

  Future<void> clearAll() async {
    await Future.wait([
      deleteToken(),
      _storage.delete(key: _kRefresh),
      deletePinHash(),
      _storage.delete(key: 'tp.wallet.pin_salt'),
    ]);
  }
}

final tokenStorageProvider = Provider<TokenStorage>((_) => TokenStorage.create());
