// lib/state/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/remote/api_exception.dart';
import '../domain/models/user.dart';
import 'api_client_provider.dart';

sealed class AuthState {
  const AuthState();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final User user;
}

class AuthError extends AuthState {
  const AuthError(this.message);
  final String message;
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._ref) : super(const AuthLoading());

  final Ref _ref;

  /// Called once at app start. Hits /me; success → authenticated, 401 →
  /// unauthenticated, anything else → error.
  Future<void> bootstrap() async {
    state = const AuthLoading();
    try {
      final api = await _ref.read(authApiProvider.future);
      final user = await api.me();
      state = AuthAuthenticated(user);
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        state = const AuthUnauthenticated();
      } else {
        state = AuthError(e.toString());
      }
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> login({required String username, required String password}) async {
    state = const AuthLoading();
    try {
      final api = await _ref.read(authApiProvider.future);
      final user = await api.login(username: username, password: password);
      state = AuthAuthenticated(user);
    } on ApiException catch (e) {
      state = AuthError(e.message);
      rethrow;
    }
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();
    try {
      final api = await _ref.read(authApiProvider.future);
      final user = await api.register(
        username: username, email: email, password: password,
      );
      state = AuthAuthenticated(user);
    } on ApiException catch (e) {
      state = AuthError(e.message);
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      final api = await _ref.read(authApiProvider.future);
      await api.logout();
    } catch (_) {/* swallow — we still log out locally */}
    state = const AuthUnauthenticated();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
