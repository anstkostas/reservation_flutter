part of 'auth_bloc.dart';

/// All states [AuthBloc] can emit.
sealed class AuthState extends Equatable {
  const AuthState();
}

/// App has just launched — session check has not yet fired.
///
/// No authenticated or unauthenticated UI should render in this state.
/// Typically shown as a splash or loading screen until [AuthCheckRequested]
/// completes and emits [AuthAuthenticated] or [AuthUnauthenticated].
final class AuthInitial extends AuthState {
  const AuthInitial();

  @override
  List<Object?> get props => [];
}

/// A login, signup, or session-check request is in-flight.
final class AuthLoading extends AuthState {
  const AuthLoading();

  @override
  List<Object?> get props => [];
}

/// A valid session exists — [user] is the authenticated user.
final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);

  final UserModel user;

  @override
  List<Object?> get props => [user];
}

/// No valid session exists, or the session has expired.
///
/// Emitted after:
/// - [AuthCheckRequested] finds no valid session (401 from `getMe`)
/// - [AuthLogoutRequested] completes — whether triggered by the user or the
///   Dio interceptor catching a 401 on any endpoint
final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();

  @override
  List<Object?> get props => [];
}

/// A login or signup request failed.
///
/// [message] is from the backend error response and is safe to display to the
/// user. Not used for session expiry — that always emits [AuthUnauthenticated].
final class AuthFailure extends AuthState {
  const AuthFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
