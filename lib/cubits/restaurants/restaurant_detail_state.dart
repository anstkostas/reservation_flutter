part of 'restaurant_detail_cubit.dart';

/// All states [RestaurantDetailCubit] can emit.
sealed class RestaurantDetailState extends Equatable {
  const RestaurantDetailState();
}

/// No fetch has been requested yet.
final class RestaurantDetailInitial extends RestaurantDetailState {
  const RestaurantDetailInitial();

  @override
  List<Object?> get props => [];
}

/// A fetch is in-flight.
final class RestaurantDetailLoading extends RestaurantDetailState {
  const RestaurantDetailLoading();

  @override
  List<Object?> get props => [];
}

/// The restaurant was fetched successfully.
final class RestaurantDetailLoaded extends RestaurantDetailState {
  const RestaurantDetailLoaded(this.restaurant);

  final RestaurantModel restaurant;

  @override
  List<Object?> get props => [restaurant];
}

/// The fetch failed.
///
/// [message] is from the backend error response and is safe to display to the user.
final class RestaurantDetailFailure extends RestaurantDetailState {
  const RestaurantDetailFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
