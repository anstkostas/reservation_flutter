import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../constants/reservation_status.dart';
import '../../../models/models.dart';
import '../../../repositories/reservation_repository.dart';

part 'owner_reservation_state.dart';

/// Manages reservations for the authenticated owner's restaurant.
///
/// ## Mutation flow
///
/// After a successful resolve, the cubit:
/// 1. Emits [OwnerReservationActionSuccess] — signals widgets to show feedback
/// 2. Immediately re-fetches and emits [OwnerReservationLoaded] with fresh data
class OwnerReservationCubit extends Cubit<OwnerReservationState> {
  OwnerReservationCubit(this._repository)
    : super(const OwnerReservationInitial());

  final ReservationRepository _repository;

  /// Fetches all reservations for the authenticated owner's restaurant.
  ///
  /// Emits [OwnerReservationLoaded] on success,
  /// [OwnerReservationFailure] if the request fails.
  Future<void> fetchOwner() async {
    emit(const OwnerReservationLoading());
    try {
      final reservations = await _repository.getOwnerReservations();
      emit(OwnerReservationLoaded(reservations));
    } on AppException catch (e) {
      emit(OwnerReservationFailure(e.message));
    }
  }

  /// Resolves the reservation with [id] to [status] (completed or no-show).
  ///
  /// Emits [OwnerReservationActionSuccess] followed by
  /// [OwnerReservationLoaded], or [OwnerReservationFailure] on error.
  Future<void> resolve({
    required String id,
    required ReservationStatus status,
  }) async {
    emit(const OwnerReservationLoading());
    try {
      await _repository.resolve(id: id, status: status);
      emit(const OwnerReservationActionSuccess());
      final reservations = await _repository.getOwnerReservations();
      emit(OwnerReservationLoaded(reservations));
    } on AppException catch (e) {
      emit(OwnerReservationFailure(e.message));
    }
  }
}
