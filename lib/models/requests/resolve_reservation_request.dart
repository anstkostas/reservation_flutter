import '../../constants/reservation_status.dart';

/// Request payload for POST /reservations/:id/resolve.
///
/// Only [ReservationStatus.completed] and [ReservationStatus.noShow]
/// are valid — the backend rejects any other status.
class ResolveReservationRequest {
  const ResolveReservationRequest({required this.status});

  final ReservationStatus status;

  /// Serializes to the shape expected by the backend resolve endpoint.
  /// Uses [ReservationStatus.toApiString] to handle the `noShow` → `"no-show"` mapping.
  Map<String, dynamic> toMap() => {'status': status.toApiString()};
}
