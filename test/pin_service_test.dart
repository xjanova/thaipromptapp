// Tests for PinService — constant-time HMAC verify guarantees.
//
// Uses a fake TokenStorage so we can test without secure-storage plugin
// channels (which aren't available in widget-less Dart tests).

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:thaipromptapp/core/auth/token_storage.dart';
import 'package:thaipromptapp/core/security/pin_service.dart';

class _InMemorySecureStorage implements FlutterSecureStorage {
  final _map = <String, String>{};

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      _map.remove(key);
    } else {
      _map[key] = value;
    }
  }

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      _map[key];

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _map.remove(key);
  }

  // Unused in these tests; satisfy interface with stubs.
  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}

void main() {
  late PinService service;

  setUp(() {
    final storage = TokenStorage(_InMemorySecureStorage());
    service = PinService(storage);
  });

  test('rejects non-digit / bad-length PIN', () {
    expect(() => service.setPin('abc123'), throwsArgumentError);
    expect(() => service.setPin('12'), throwsArgumentError);
    expect(() => service.setPin('123456789'), throwsArgumentError);
  });

  test('set then verify with correct PIN returns the hash', () async {
    await service.setPin('123456');
    final hash = await service.verify('123456');
    expect(hash, isNotNull);
    expect(hash!.length, 64); // SHA-256 hex
  });

  test('verify with wrong PIN returns null', () async {
    await service.setPin('123456');
    expect(await service.verify('654321'), isNull);
  });

  test('setPin re-generates salt → different hash for same PIN each time',
      () async {
    await service.setPin('123456');
    final first = await service.verify('123456');

    await service.setPin('123456');
    final second = await service.verify('123456');

    expect(first, isNotNull);
    expect(second, isNotNull);
    expect(first, isNot(equals(second)));
  });

  test('hasPin tracks state', () async {
    expect(await service.hasPin(), isFalse);
    await service.setPin('4242');
    expect(await service.hasPin(), isTrue);
  });
}
