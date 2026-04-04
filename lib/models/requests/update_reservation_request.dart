/// Request payload for PUT /reservations/:id.
///
/// At least one field must be non-null — enforced by the backend.
class UpdateReservationRequest {
  const UpdateReservationRequest({this.scheduledAt, this.people});

  final DateTime? scheduledAt;
  final int? people;

  /// Serializes to the shape expected by the backend update reservation endpoint.
  /// Null fields are omitted — the backend requires at least one field to be present.
  Map<String, dynamic> toMap() => {
    if (scheduledAt != null) 'scheduledAt': scheduledAt!.toUtc().toIso8601String(),
    if (people != null) 'people': people,
  };
}
