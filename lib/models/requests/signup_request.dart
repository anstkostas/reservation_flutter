/// Request payload for POST /auth/signup.
///
/// [restaurantId] is optional — if provided, the server derives the role
/// as `owner`. The server ignores any `role` field; role is always
/// determined server-side from [restaurantId].
class SignupRequest {
  const SignupRequest({
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

  /// Serializes to the shape expected by the backend signup endpoint.
  /// [restaurantId] is omitted from the map when null.
  Map<String, dynamic> toMap() => {
    'firstname': firstname,
    'lastname': lastname,
    'email': email,
    'password': password,
    if (restaurantId != null) 'restaurantId': restaurantId,
  };
}
