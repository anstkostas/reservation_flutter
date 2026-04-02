part of 'customer_reservation_cubit.dart';

/// All states [CustomerReservationCubit] can emit.
sealed class CustomerReservationState extends Equatable {
  const CustomerReservationState();
}

/// No fetch has been requested yet.
final class CustomerReservationInitial extends CustomerReservationState {
  const CustomerReservationInitial();

  @override
  List<Object?> get props => [];
}

/// A fetch or mutation is in-flight.
final class CustomerReservationLoading extends CustomerReservationState {
  const CustomerReservationLoading();

  @override
  List<Object?> get props => [];
}

/// Reservations were fetched successfully.
final class CustomerReservationLoaded extends CustomerReservationState {
  const CustomerReservationLoaded(this.reservations);

  final List<ReservationModel> reservations;

  @override
  List<Object?> get props => [reservations];
}

/// A create, update, or cancel mutation completed successfully.
///
/// Emitted immediately before the cubit re-fetches and emits
/// [CustomerReservationLoaded] with fresh data. Widgets can listen for this
/// state to show a brief success indicator.
final class CustomerReservationActionSuccess extends CustomerReservationState {
  const CustomerReservationActionSuccess();

  @override
  List<Object?> get props => [];
}

/// A fetch or mutation failed.
///
/// [message] is from the backend error response and is safe to display to the user.
final class CustomerReservationFailure extends CustomerReservationState {
  const CustomerReservationFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
