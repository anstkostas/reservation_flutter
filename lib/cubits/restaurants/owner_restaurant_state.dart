part of 'owner_restaurant_cubit.dart';

/// All states [OwnerRestaurantCubit] can emit.
sealed class OwnerRestaurantState extends Equatable {
  const OwnerRestaurantState();
}

/// No fetch has been requested yet.
final class OwnerRestaurantInitial extends OwnerRestaurantState {
  const OwnerRestaurantInitial();

  @override
  List<Object?> get props => [];
}

/// A fetch or update is in-flight.
final class OwnerRestaurantLoading extends OwnerRestaurantState {
  const OwnerRestaurantLoading();

  @override
  List<Object?> get props => [];
}

/// The restaurant was fetched or updated successfully.
final class OwnerRestaurantLoaded extends OwnerRestaurantState {
  const OwnerRestaurantLoaded(this.restaurant);

  final RestaurantPrivateModel restaurant;

  @override
  List<Object?> get props => [restaurant];
}

/// An update completed successfully.
///
/// Emitted immediately before the cubit re-fetches and emits [OwnerRestaurantLoaded].
/// The edit screen listens for this state to show a snackbar and pop back to the dashboard.
final class OwnerRestaurantUpdateSuccess extends OwnerRestaurantState {
  const OwnerRestaurantUpdateSuccess();

  @override
  List<Object?> get props => [];
}

/// A fetch failed.
///
/// [message] is from the backend and is safe to display.
/// [code] is the machine-readable error code for localized string lookup.
final class OwnerRestaurantFailure extends OwnerRestaurantState {
  const OwnerRestaurantFailure(this.message, {this.code});

  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];
}

/// An update failed.
///
/// Unlike [OwnerRestaurantFailure] (fetch errors), this keeps the form visible.
/// [details] carries per-field errors from a VALIDATION_ERROR response — each
/// entry has at minimum `field` and `message` keys. Null for non-validation failures.
final class OwnerRestaurantUpdateFailure extends OwnerRestaurantState {
  const OwnerRestaurantUpdateFailure(this.message, {this.code, this.details});

  final String message;
  final String? code;
  final List<Map<String, dynamic>>? details;

  @override
  List<Object?> get props => [message, code, details];
}
