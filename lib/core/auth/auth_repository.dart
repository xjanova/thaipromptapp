import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../api/endpoints.dart';
import '../../shared/models/user.dart';
import 'token_storage.dart';

/// Thin abstraction over /v1 auth endpoints.
/// Repositories NEVER touch UI state directly — controllers consume this.
class AuthRepository {
  AuthRepository(this._api, this._storage);

  final ApiClient _api;
  final TokenStorage _storage;

  /// Login with email/phone + password. Returns the authenticated [TpUser].
  /// Also persists the Sanctum token in secure storage.
  Future<TpUser> login({required String identifier, required String password}) async {
    final data = await _api.post<Map<String, dynamic>>(
      Api.login,
      data: {
        'email': identifier,  // backend accepts email or phone in this field
        'password': password,
        'device_name': 'thaipromptapp',
      },
    );
    final token = data['token'] ?? data['access_token'];
    if (token is! String || token.isEmpty) {
      throw StateError('เซิร์ฟเวอร์ไม่ส่ง token · โปรดติดต่อผู้ดูแล');
    }
    await _storage.writeToken(token);
    return TpUser.fromJson(data);
  }

  /// Register a new user. Backend returns both profile + token.
  Future<TpUser> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? referralCode,
  }) async {
    final data = await _api.post<Map<String, dynamic>>(
      Api.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
        if (phone != null) 'phone': phone,
        if (referralCode != null) 'referral_code': referralCode,
      },
    );
    final token = data['token'] ?? data['access_token'];
    if (token is String && token.isNotEmpty) {
      await _storage.writeToken(token);
    }
    return TpUser.fromJson(data);
  }

  Future<TpUser> me() async {
    final data = await _api.get<Map<String, dynamic>>(Api.me);
    return TpUser.fromJson(data);
  }

  /// LINE native login: exchange LINE access token for Sanctum token.
  Future<TpUser> lineLogin({required String accessToken, required String idToken}) async {
    final data = await _api.post<Map<String, dynamic>>(
      Api.lineNativeVerify,
      data: {
        'access_token': accessToken,
        'id_token': idToken,
      },
    );
    final token = data['token'] ?? data['access_token'];
    if (token is String && token.isNotEmpty) {
      await _storage.writeToken(token);
    }
    return TpUser.fromJson(data);
  }

  Future<void> logout() async {
    try {
      await _api.post<void>(Api.logout);
    } catch (_) {
      // Best-effort — token gets cleared regardless.
    }
    await _storage.clearAll();
  }

  /// Check if we have a token; does NOT validate it with the server.
  Future<bool> hasToken() async {
    final t = await _storage.readToken();
    return t != null && t.isNotEmpty;
  }
}

final authRepositoryProvider = FutureProvider<AuthRepository>((ref) async {
  final api = await ref.watch(apiClientProvider.future);
  final storage = ref.watch(tokenStorageProvider);
  return AuthRepository(api, storage);
});
