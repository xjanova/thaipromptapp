import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/token_storage.dart';

/// Wallet PIN service.
///
/// Security rules (from global CLAUDE.md §B):
/// - Never log or display the raw PIN.
/// - Never store raw PIN on-device — only HMAC-SHA256 with a per-device salt.
/// - Use constant-time comparison on verify to avoid timing side-channels.
/// - Per-device salt lives in encrypted secure storage alongside the hash.
///
/// Flow:
/// 1. First time: user creates a PIN → we generate a 32-byte salt, compute
///    hash = HMAC-SHA256(salt, pin), store both.
/// 2. Transfer: prompt PIN, compute hash, constant-time-compare with stored
///    hash. Pass hash (NOT raw PIN) to the backend `/v1/wallet/transfer`.
/// 3. Lost PIN: user must call support (out-of-band) to reset; backend owns
///    that flow via LINE OA.
class PinService {
  PinService(this._storage);
  final TokenStorage _storage;

  static const _kSalt = 'tp.wallet.pin_salt';

  Future<bool> hasPin() async => (await _storage.readPinHash()) != null;

  /// Set a new PIN. Overwrites existing hash.
  /// Returns the stored hash (hex) for immediate use in a transfer call.
  Future<String> setPin(String pin) async {
    _assertPinFormat(pin);
    final salt = _generateSalt();
    final hash = _hmac(salt, pin);
    await _storage.writePinHash(hash);
    // Salt is co-located next to the hash, in secure storage.
    // (We don't expose a dedicated writeSalt on TokenStorage — use a direct call.)
    await _storage.writePinHashSalt(_kSalt, salt);
    return hash;
  }

  /// Verify and return the hash if correct, else null.
  /// Constant-time comparison across the full hash length.
  Future<String?> verify(String pin) async {
    _assertPinFormat(pin);
    final salt = await _storage.readPinHashSalt(_kSalt);
    final stored = await _storage.readPinHash();
    if (salt == null || stored == null) return null;
    final candidate = _hmac(salt, pin);
    return _constantTimeEquals(candidate, stored) ? stored : null;
  }

  String _hmac(String saltHex, String pin) {
    final key = _hexToBytes(saltHex);
    final mac = Hmac(sha256, key).convert(utf8.encode(pin));
    return mac.toString();
  }

  String _generateSalt() {
    final rng = Random.secure();
    final bytes = List<int>.generate(32, (_) => rng.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  List<int> _hexToBytes(String hex) => [
        for (var i = 0; i < hex.length; i += 2)
          int.parse(hex.substring(i, i + 2), radix: 16),
      ];

  void _assertPinFormat(String pin) {
    if (pin.length < 4 || pin.length > 8) {
      throw ArgumentError('PIN must be 4–8 digits');
    }
    for (final c in pin.codeUnits) {
      if (c < 0x30 || c > 0x39) throw ArgumentError('PIN must be digits only');
    }
  }

  /// XOR-based constant-time string compare.
  bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}

final pinServiceProvider = FutureProvider<PinService>((ref) async {
  final storage = await ref.watch(tokenStorageProvider.future);
  return PinService(storage);
});
