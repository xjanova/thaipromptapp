import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/user.dart';
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
    try {
      final repo = await ref.read(authRepositoryProvider.future);
      if (!await repo.hasToken()) {
        state = const AuthUnauthenticated();
        return;
      }
      final user = await repo.me();
      state = AuthAuthenticated(user);
    } catch (_) {
      state = const AuthUnauthenticated();
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
