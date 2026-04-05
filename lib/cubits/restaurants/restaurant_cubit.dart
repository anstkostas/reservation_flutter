import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../models/models.dart';
import '../../repositories/restaurant_repository.dart';

part 'restaurant_state.dart';

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
      if (isClosed) return;
      emit(UnownedLoaded(restaurants));
    } on AppException catch (e) {
      if (isClosed) return;
      emit(UnownedFailure(e.message));
    }
  }
}
