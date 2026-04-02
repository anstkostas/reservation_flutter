part of 'owner_reservation_cubit.dart';

/// All states [OwnerReservationCubit] can emit.
sealed class OwnerReservationState extends Equatable {
  const OwnerReservationState();
}

/// No fetch has been requested yet.
final class OwnerReservationInitial extends OwnerReservationState {
  const OwnerReservationInitial();

  @override
  List<Object?> get props => [];
}

/// A fetch or mutation is in-flight.
final class OwnerReservationLoading extends OwnerReservationState {
  const OwnerReservationLoading();

  @override
  List<Object?> get props => [];
}

/// Reservations were fetched successfully.
final class OwnerReservationLoaded extends OwnerReservationState {
  const OwnerReservationLoaded(this.reservations);

  final List<ReservationModel> reservations;

  @override
  List<Object?> get props => [reservations];
}

/// A resolve mutation (completed or no-show) completed successfully.
///
/// Emitted immediately before the cubit re-fetches and emits
/// [OwnerReservationLoaded] with fresh data. Widgets can listen for this
/// state to show a brief success indicator.
final class OwnerReservationActionSuccess extends OwnerReservationState {
  const OwnerReservationActionSuccess();

  @override
  List<Object?> get props => [];
}

/// A fetch or mutation failed.
///
/// [message] is from the backend error response and is safe to display to the user.
final class OwnerReservationFailure extends OwnerReservationState {
  const OwnerReservationFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
