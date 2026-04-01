/// Request payload for POST /reservations/restaurants/:restaurantId.
class CreateReservationRequest {
  const CreateReservationRequest({
    required this.scheduledAt,
    required this.people,
  });

  final DateTime scheduledAt;
  final int people;

  /// Serializes to the shape expected by the backend create reservation endpoint.
  /// [scheduledAt] is converted to ISO 8601 format.
  Map<String, dynamic> toMap() => {
    'scheduledAt': scheduledAt.toIso8601String(),
    'people': people,
  };
}
