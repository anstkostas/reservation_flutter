/// Request payload for POST /auth/login.
class LoginRequest {
  const LoginRequest({required this.email, required this.password});

  final String email;
  final String password;

  /// Serializes to the shape expected by the backend login endpoint.
  Map<String, dynamic> toMap() => {'email': email, 'password': password};
}
