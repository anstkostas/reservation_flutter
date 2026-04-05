import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../models/models.dart';
import '../../repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Manages authentication state for the entire application.
///
/// ## Why BLoC, not Cubit
///
/// Auth state is driven by named, dispatchable events — not just direct method
/// calls from widgets. The key reason is the Dio interceptor:
///
/// ```dart
/// // DioClient._onError — fires on any 401, from any endpoint:
/// getIt<AuthBloc>().add(const AuthLogoutRequested());
/// ```
///
/// This lets any API call transparently log the user out on session expiry,
/// without any individual Cubit needing to know about auth. The event model
/// makes the external trigger explicit and visible in BLoC DevTools.
///
/// ## Event → State transitions
///
/// ```
/// AuthCheckRequested  → AuthLoading → AuthAuthenticated | AuthUnauthenticated
/// AuthLoginRequested  → AuthLoading → AuthAuthenticated | AuthFailure
/// AuthSignupRequested → AuthLoading → AuthAuthenticated | AuthFailure
/// AuthLogoutRequested →              AuthUnauthenticated  (no loading)
/// ```
///
/// ## Session expiry vs login failure
///
/// A 401 on `getMe` (session check) is **not** an error — it means no active
/// session exists. It emits [AuthUnauthenticated], not [AuthFailure].
/// [AuthFailure] is only emitted for login/signup validation errors.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repository) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthSignupRequested>(_onSignupRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  final AuthRepository _repository;

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _repository.getMe();
      emit(AuthAuthenticated(user));
    } on UnauthorizedException {
      // No active session — expected on first launch or after expiry.
      // Emit AuthUnauthenticated, not AuthFailure — this is not an error.
      emit(const AuthUnauthenticated());
    } on AppException {
      // Any non-401 error during session check (network, 404, etc.) still
      // means the user is not authenticated — emit AuthUnauthenticated, not
      // AuthFailure. AuthFailure is reserved for login/signup form errors.
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _repository.login(event.email, event.password);
      emit(AuthAuthenticated(user));
    } on AppException catch (e) {
      emit(AuthFailure(e.message));
    }
  }

  Future<void> _onSignupRequested(
    AuthSignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _repository.signup(
        firstname: event.firstname,
        lastname: event.lastname,
        email: event.email,
        password: event.password,
        restaurantId: event.restaurantId,
      );
      emit(AuthAuthenticated(user));
    } on AppException catch (e) {
      emit(AuthFailure(e.message));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    // No loading state — logout is fire-and-forget from the user's perspective.
    // Even if the server call fails, clear local state immediately so the user
    // is always sent back to the login screen.
    try {
      await _repository.logout();
    } catch (_) {
      // Server-side logout is best-effort. The auth cookie is managed by the
      // server — if the call fails, the cookie will expire on its own.
    }
    emit(const AuthUnauthenticated());
  }
}
