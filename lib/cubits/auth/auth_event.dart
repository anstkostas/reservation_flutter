part of 'auth_bloc.dart';

/// All events [AuthBloc] can receive.
///
/// ## Why BLoC events instead of Cubit methods
///
/// Auth uses BLoC (not Cubit) because [AuthLogoutRequested] must be
/// dispatchable from outside the widget tree — specifically from the Dio
/// interceptor when any API call returns 401:
///
/// ```dart
/// getIt<AuthBloc>().add(const AuthLogoutRequested());
/// ```
///
/// Named events make this external dispatch explicit and traceable. Two
/// independent triggers — user tapping logout and a 401 response from any
/// endpoint — both fire the same [AuthLogoutRequested] event, so the logout
/// logic lives in exactly one place.
sealed class AuthEvent extends Equatable {
  const AuthEvent();
}

/// Fired on app startup to check whether a valid session cookie exists.
///
/// [AuthBloc] calls [AuthRepository.getMe]:
/// - Success → emits [AuthAuthenticated]
/// - 401 (no session) → emits [AuthUnauthenticated] (expected, not an error)
/// - Other error → emits [AuthFailure]
final class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();

  @override
  List<Object?> get props => [];
}

/// Fired when the user submits the login form.
final class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

/// Fired when the user submits the signup form.
///
/// [restaurantId] is optional — if provided, the account is created as
/// owner of that restaurant. Role is derived server-side; never sent by client.
final class AuthSignupRequested extends AuthEvent {
  const AuthSignupRequested({
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.password,
    this.restaurantId,
  });

  final String firstname;
  final String lastname;
  final String email;
  final String password;
  final String? restaurantId;

  @override
  List<Object?> get props => [
    firstname,
    lastname,
    email,
    password,
    restaurantId,
  ];
}

/// Fired in two independent scenarios — both handled identically:
///
/// 1. **User action** — user taps the logout button in the UI.
/// 2. **Session expiry** — the Dio interceptor receives a 401 from any API
///    call and dispatches this event via `getIt<AuthBloc>()`. No individual
///    Cubit needs to handle session expiry; it is all centralised here.
final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();

  @override
  List<Object?> get props => [];
}
