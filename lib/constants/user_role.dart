/// User role values matching the backend Role enum.
enum UserRole {
  customer,
  owner;

  /// Maps a raw API string to a [UserRole].
  /// Throws [ArgumentError] for unrecognised values.
  static UserRole fromString(String value) {
    return switch (value) {
      'customer' => UserRole.customer,
      'owner' => UserRole.owner,
      _ => throw ArgumentError('Unknown UserRole: $value'),
    };
  }
}
