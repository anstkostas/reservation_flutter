/// Reservation status values matching the backend ReservationStatus enum.
enum ReservationStatus {
  active,
  canceled,
  completed,
  noShow;

  /// Maps a raw API string to a [ReservationStatus].
  /// Throws [ArgumentError] for unrecognised values.
  static ReservationStatus fromString(String value) {
    return switch (value) {
      'active' => ReservationStatus.active,
      'canceled' => ReservationStatus.canceled,
      'completed' => ReservationStatus.completed,
      'no-show' => ReservationStatus.noShow,
      _ => throw ArgumentError('Unknown ReservationStatus: $value'),
    };
  }
}
