part of 'restaurant_list_cubit.dart';

/// All states [RestaurantListCubit] can emit.
sealed class RestaurantListState extends Equatable {
  const RestaurantListState();
}

/// No fetch has been requested yet.
final class RestaurantListInitial extends RestaurantListState {
  const RestaurantListInitial();

  @override
  List<Object?> get props => [];
}

/// A fetch is in-flight.
final class RestaurantListLoading extends RestaurantListState {
  const RestaurantListLoading();

  @override
  List<Object?> get props => [];
}

/// All restaurants were fetched successfully.
final class RestaurantListLoaded extends RestaurantListState {
  const RestaurantListLoaded(this.restaurants);

  final List<RestaurantModel> restaurants;

  @override
  List<Object?> get props => [restaurants];
}

/// The fetch failed.
///
/// [message] is from the backend error response and is safe to display to the user.
final class RestaurantListFailure extends RestaurantListState {
  const RestaurantListFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
