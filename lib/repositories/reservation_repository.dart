import '../constants/reservation_status.dart';
import '../models/models.dart';
import '../services/reservation_service.dart';

/// Maps raw reservation API responses to typed models.
///
/// Builds request models from domain values — callers pass primitives,
/// this layer owns the request shape. Exceptions from [ReservationService]
/// propagate upward without being caught here:
/// - [UnauthorizedException] is caught by [AuthBloc] and emits [AuthUnauthenticated]
/// - [AppException] is caught by the relevant Cubit and emits a failure state
class ReservationRepository {
  ReservationRepository(this._service);

  final ReservationService _service;

  /// Returns all active reservations for the authenticated customer.
  ///
  /// Throws [AppException] on network error.
  Future<List<ReservationModel>> getMyReservations() async {
    final data = await _service.getMyReservations();
    return data
        .cast<Map<String, dynamic>>()
        .map(ReservationModel.fromJson)
        .toList();
  }

  /// Returns all reservations for the authenticated owner's restaurant.
  ///
  /// Throws [AppException] on network error.
  Future<List<ReservationModel>> getOwnerReservations() async {
    final data = await _service.getOwnerReservations();
    return data
        .cast<Map<String, dynamic>>()
        .map(ReservationModel.fromJson)
        .toList();
  }

  /// Creates a reservation at [restaurantId] and returns the created [ReservationModel].
  ///
  /// Throws [AppException] on validation error or network error.
  Future<ReservationModel> create({
    required String restaurantId,
    required DateTime scheduledAt,
    required int people,
  }) async {
    final data = await _service.create(
      restaurantId,
      CreateReservationRequest(scheduledAt: scheduledAt, people: people),
    );
    return ReservationModel.fromJson(data);
  }

  /// Updates the reservation with [id] and returns the updated [ReservationModel].
  ///
  /// At least one of [scheduledAt] or [people] must be non-null — enforced by the backend.
  /// Throws [AppException] on validation error or network error.
  Future<ReservationModel> update({
    required String id,
    DateTime? scheduledAt,
    int? people,
  }) async {
    final data = await _service.update(
      id,
      UpdateReservationRequest(scheduledAt: scheduledAt, people: people),
    );
    return ReservationModel.fromJson(data);
  }

  /// Soft-cancels the reservation with [id].
  ///
  /// No row is deleted on the server — status is set to `canceled`.
  /// Throws [AppException] on network error.
  Future<void> cancel(String id) => _service.cancel(id);

  /// Resolves the reservation with [id] to [status] (completed or no-show).
  ///
  /// Owner-only. Returns the updated [ReservationModel].
  /// Throws [AppException] on validation error or network error.
  Future<ReservationModel> resolve({
    required String id,
    required ReservationStatus status,
  }) async {
    final data = await _service.resolve(
      id,
      ResolveReservationRequest(status: status),
    );
    return ReservationModel.fromJson(data);
  }
}
