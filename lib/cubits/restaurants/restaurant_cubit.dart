import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../models/models.dart';
import '../../repositories/restaurant_repository.dart';

part 'restaurant_state.dart';

/// Fetches and holds restaurant list and individual restaurant data.
///
/// Covers both the restaurant list screen ([fetchAll]) and the detail screen
/// ([fetchById]). The two loaded states are separate so navigating to a detail
/// view does not clear the list that the user came from.
class RestaurantCubit extends Cubit<RestaurantState> {
  RestaurantCubit(this._repository) : super(const RestaurantInitial());

  final RestaurantRepository _repository;

  /// Fetches all restaurants and emits [RestaurantLoaded] on success.
  ///
  /// Emits [RestaurantFailure] with the error message if the request fails.
  Future<void> fetchAll() async {
    emit(const RestaurantLoading());
    try {
      final restaurants = await _repository.getAll();
      emit(RestaurantLoaded(restaurants));
    } on AppException catch (e) {
      emit(RestaurantFailure(e.message));
    }
  }

  /// Fetches the restaurant with [id] and emits [RestaurantDetailLoaded] on success.
  ///
  /// Emits [RestaurantFailure] with the error message if the request fails.
  Future<void> fetchById(String id) async {
    emit(const RestaurantLoading());
    try {
      final restaurant = await _repository.getById(id);
      emit(RestaurantDetailLoaded(restaurant));
    } on AppException catch (e) {
      emit(RestaurantFailure(e.message));
    }
  }
}

/// Fetches and holds the list of restaurants that have no owner.
///
/// Scoped to the signup screen subtree only — not provided at app level.
/// Lets a new owner claim a restaurant during the signup flow.
class UnownedRestaurantCubit extends Cubit<UnownedRestaurantState> {
  UnownedRestaurantCubit(this._repository) : super(const UnownedInitial());

  final RestaurantRepository _repository;

  /// Fetches all unowned restaurants and emits [UnownedLoaded] on success.
  ///
  /// Emits [UnownedFailure] with the error message if the request fails.
  Future<void> fetchUnowned() async {
    emit(const UnownedLoading());
    try {
      final restaurants = await _repository.getUnowned();
      emit(UnownedLoaded(restaurants));
    } on AppException catch (e) {
      emit(UnownedFailure(e.message));
    }
  }
}
