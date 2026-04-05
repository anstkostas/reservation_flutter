part of 'restaurant_cubit.dart';

/// All states [UnownedRestaurantCubit] can emit.
sealed class UnownedRestaurantState extends Equatable {
  const UnownedRestaurantState();
}

/// No fetch has been requested yet.
final class UnownedInitial extends UnownedRestaurantState {
  const UnownedInitial();

  @override
  List<Object?> get props => [];
}

/// A fetch is in-flight.
final class UnownedLoading extends UnownedRestaurantState {
  const UnownedLoading();

  @override
  List<Object?> get props => [];
}

/// Unowned restaurants were fetched successfully.
final class UnownedLoaded extends UnownedRestaurantState {
  const UnownedLoaded(this.restaurants);

  final List<RestaurantModel> restaurants;

  @override
  List<Object?> get props => [restaurants];
}

/// A fetch failed.
///
/// [message] is from the backend error response and is safe to display to the user.
final class UnownedFailure extends UnownedRestaurantState {
  const UnownedFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
