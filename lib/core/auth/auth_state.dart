import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/user.dart';
import '../api/api_exceptions.dart';
import 'auth_repository.dart';

/// Authentication status observable by the whole app.
sealed class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => const [];
}

class AuthUnknown extends AuthState {
  const AuthUnknown();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final TpUser user;
  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated({this.reason});
  final String? reason;
  @override
  List<Object?> get props => [reason];
}

/// Single source of truth for auth state.
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    _bootstrap();
    return const AuthUnknown();
  }

  Future<void> _bootstrap() async {
    final AuthRepository repo;
    try {
      repo = await ref.read(authRepositoryProvider.future);
    } catch (e, st) {
      if (kDebugMode) debugPrint('[AuthController] repo init failed: $e\n$st');
      state = const AuthUnauthenticated();
      return;
    }

    final hasToken = await repo.hasToken().catchError((_) => false);
    if (!hasToken) {
      state = const AuthUnauthenticated();
      return;
    }

    // We have a persisted token. Trust it optimistically so the user
    // doesn't get bounced to /login on every cold start just because
    // their network was flaky at launch. Only drop to Unauthenticated
    // on a HARD 401 (token actually invalid); any other failure
    // (timeout, no internet, 5xx) keeps the session so they can retry
    // without re-entering credentials.
    try {
      final user = await repo.me();
      state = AuthAuthenticated(user);
    } on UnauthorizedException {
      // Token rejected by server → really logged out. Interceptor
      // already cleared storage on 401.
      state = const AuthUnauthenticated();
    } on ApiException catch (e) {
      if (kDebugMode) {
        debugPrint(
            '[AuthController] transient /me failure — staying optimistic: $e');
      }
      state = AuthAuthenticated(TpUser.placeholder());
      // Best-effort refresh shortly after (network likely back by then).
      Future.delayed(const Duration(seconds: 4), _retryMeSilently);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[AuthController] unexpected /me error: $e\n$st');
      }
      // Non-API error — still prefer optimistic over forced logout.
      state = AuthAuthenticated(TpUser.placeholder());
      Future.delayed(const Duration(seconds: 4), _retryMeSilently);
    }
  }

  Future<void> _retryMeSilently() async {
    if (state is! AuthAuthenticated) return;
    try {
      final repo = await ref.read(authRepositoryProvider.future);
      final user = await repo.me();
      state = AuthAuthenticated(user);
    } catch (_) {
      // Leave the placeholder in place; the next authenticated call
      // will either succeed or trigger a 401 → clean logout.
    }
  }

  Future<void> login({required String identifier, required String password}) async {
    final repo = await ref.read(authRepositoryProvider.future);
    final user = await repo.login(identifier: identifier, password: password);
    state = AuthAuthenticated(user);
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
    String? referralCode,
  }) async {
    final repo = await ref.read(authRepositoryProvider.future);
    final user = await repo.register(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
      phone: phone,
      referralCode: referralCode,
    );
    state = AuthAuthenticated(user);
  }

  Future<void> logout() async {
    final repo = await ref.read(authRepositoryProvider.future);
    await repo.logout();
    state = const AuthUnauthenticated();
  }

  /// Called by interceptors when a 401 escapes user-triggered flows.
  void forceUnauthenticated({String? reason}) {
    state = AuthUnauthenticated(reason: reason);
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
