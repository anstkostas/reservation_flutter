import '../models/models.dart';
import '../services/auth_service.dart';

/// Maps raw auth API responses to typed models.
///
/// Builds request models from domain values — callers pass primitives,
/// this layer owns the request shape. Exceptions from [AuthService]
/// propagate upward without being caught here:
/// - [UnauthorizedException] is caught by [AuthBloc] and emits [AuthUnauthenticated]
/// - [AppException] is caught by [AuthBloc] and emits [AuthFailure]
class AuthRepository {
  AuthRepository(this._service);

  final AuthService _service;

  /// Authenticates a user and returns the authenticated [UserModel].
  ///
  /// Throws [AppException] on invalid credentials or network error.
  Future<UserModel> login(String email, String password) async {
    final data = await _service.login(
      LoginRequest(email: email, password: password),
    );
    return UserModel.fromJson(data);
  }

  /// Creates a new user account and returns the created [UserModel].
  ///
  /// [restaurantId] is optional — if provided, the account is created
  /// as owner of that restaurant.
  ///
  /// Throws [AppException] on validation error or network error.
  Future<UserModel> signup({
    required String firstname,
    required String lastname,
    required String email,
    required String password,
    String? restaurantId,
  }) async {
    final data = await _service.signup(
      SignupRequest(
        firstname: firstname,
        lastname: lastname,
        email: email,
        password: password,
        restaurantId: restaurantId,
      ),
    );
    return UserModel.fromJson(data);
  }

  /// Clears the server-side auth cookie.
  ///
  /// Throws [AppException] on network error.
  Future<void> logout() => _service.logout();

  /// Returns the [UserModel] for the currently authenticated session.
  ///
  /// Throws [UnauthorizedException] if no valid session exists.
  /// Throws [AppException] on network error.
  Future<UserModel> getMe() async {
    final data = await _service.getMe();
    return UserModel.fromJson(data);
  }
}
