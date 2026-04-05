import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../models/models.dart';
import '../../repositories/restaurant_repository.dart';

part 'restaurant_list_state.dart';

/// Fetches and holds the full list of restaurants.
///
/// Scoped to the restaurant list screen. Each [BlocProvider] subtree gets a
/// fresh instance via the factory registration in get_it.
class RestaurantListCubit extends Cubit<RestaurantListState> {
  RestaurantListCubit(this._repository) : super(const RestaurantListInitial());

  final RestaurantRepository _repository;

  /// Fetches all restaurants and emits [RestaurantListLoaded] on success.
  ///
  /// Emits [RestaurantListFailure] with the error message if the request fails.
  Future<void> fetchAll() async {
    emit(const RestaurantListLoading());
    try {
      final restaurants = await _repository.getAll();
      if (isClosed) return;
      emit(RestaurantListLoaded(restaurants));
    } on AppException catch (e) {
      if (isClosed) return;
      emit(RestaurantListFailure(e.message));
    }
  }
}
