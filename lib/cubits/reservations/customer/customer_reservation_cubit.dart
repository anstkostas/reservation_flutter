import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../models/models.dart';
import '../../../repositories/reservation_repository.dart';

part 'customer_reservation_state.dart';

/// Manages the authenticated customer's reservations.
///
/// ## Mutation flow
///
/// After every successful mutation (create, update, cancel), the cubit:
/// 1. Emits [CustomerReservationActionSuccess] — signals widgets to show feedback
/// 2. Immediately re-fetches and emits [CustomerReservationLoaded] with fresh data
///
/// This keeps the list in sync without requiring the screen to trigger a
/// separate fetch after a mutation.
class CustomerReservationCubit extends Cubit<CustomerReservationState> {
  CustomerReservationCubit(this._repository)
    : super(const CustomerReservationInitial());

  final ReservationRepository _repository;

  /// Fetches all reservations for the authenticated customer.
  ///
  /// Emits [CustomerReservationLoaded] on success,
  /// [CustomerReservationFailure] if the request fails.
  Future<void> fetchMine() async {
    emit(const CustomerReservationLoading());
    try {
      final reservations = await _repository.getMyReservations();
      if (isClosed) return;
      emit(CustomerReservationLoaded(reservations));
    } on AppException catch (e) {
      if (isClosed) return;
      emit(CustomerReservationFailure(e.message));
    }
  }

  /// Creates a reservation and re-fetches the list on success.
  ///
  /// Emits [CustomerReservationActionSuccess] followed by
  /// [CustomerReservationLoaded], or [CustomerReservationFailure] on error.
  Future<void> create({
    required String restaurantId,
    required DateTime scheduledAt,
    required int people,
  }) async {
    emit(const CustomerReservationLoading());
    try {
      await _repository.create(
        restaurantId: restaurantId,
        scheduledAt: scheduledAt,
        people: people,
      );
      if (isClosed) return;
      emit(const CustomerReservationActionSuccess());
      final reservations = await _repository.getMyReservations();
      if (isClosed) return;
      emit(CustomerReservationLoaded(reservations));
    } on AppException catch (e) {
      if (isClosed) return;
      emit(CustomerReservationFailure(e.message));
    }
  }

  /// Updates the reservation with [id] and re-fetches the list on success.
  ///
  /// At least one of [scheduledAt] or [people] must be non-null.
  /// Emits [CustomerReservationActionSuccess] followed by
  /// [CustomerReservationLoaded], or [CustomerReservationFailure] on error.
  Future<void> update({
    required String id,
    DateTime? scheduledAt,
    int? people,
  }) async {
    emit(const CustomerReservationLoading());
    try {
      await _repository.update(
        id: id,
        scheduledAt: scheduledAt,
        people: people,
      );
      if (isClosed) return;
      emit(const CustomerReservationActionSuccess());
      final reservations = await _repository.getMyReservations();
      if (isClosed) return;
      emit(CustomerReservationLoaded(reservations));
    } on AppException catch (e) {
      if (isClosed) return;
      emit(CustomerReservationFailure(e.message));
    }
  }

  /// Soft-cancels the reservation with [id] and re-fetches the list on success.
  ///
  /// Emits [CustomerReservationActionSuccess] followed by
  /// [CustomerReservationLoaded], or [CustomerReservationFailure] on error.
  Future<void> cancel(String id) async {
    emit(const CustomerReservationLoading());
    try {
      await _repository.cancel(id);
      if (isClosed) return;
      emit(const CustomerReservationActionSuccess());
      final reservations = await _repository.getMyReservations();
      if (isClosed) return;
      emit(CustomerReservationLoaded(reservations));
    } on AppException catch (e) {
      if (isClosed) return;
      emit(CustomerReservationFailure(e.message));
    }
  }
}
