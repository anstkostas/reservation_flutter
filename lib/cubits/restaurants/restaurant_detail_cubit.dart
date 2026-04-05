import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../models/models.dart';
import '../../repositories/restaurant_repository.dart';

part 'restaurant_detail_state.dart';

/// Fetches and holds a single restaurant's detail.
///
/// Scoped to the restaurant detail route — a fresh instance is created on
/// every navigation to `/restaurants/:id` via the route-level [BlocProvider]
/// in the router. This ensures stale data from a previous detail visit never
/// bleeds into a new one.
class RestaurantDetailCubit extends Cubit<RestaurantDetailState> {
  RestaurantDetailCubit(this._repository)
      : super(const RestaurantDetailInitial());

  final RestaurantRepository _repository;

  /// Fetches the restaurant with [id] and emits [RestaurantDetailLoaded] on success.
  ///
  /// Emits [RestaurantDetailFailure] with the error message if the request fails.
  Future<void> fetchById(String id) async {
    emit(const RestaurantDetailLoading());
    try {
      final restaurant = await _repository.getById(id);
      if (isClosed) return;
      emit(RestaurantDetailLoaded(restaurant));
    } on AppException catch (e) {
      if (isClosed) return;
      emit(RestaurantDetailFailure(e.message));
    }
  }
}
