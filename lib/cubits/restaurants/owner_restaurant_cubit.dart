import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:antigravity_client/models/models.dart';
import 'package:antigravity_client/repositories/restaurant_repository.dart';

part 'owner_restaurant_state.dart';

/// Manages the authenticated owner's own restaurant — fetch for pre-fill and update.
///
/// ## Update flow
///
/// After a successful update, the cubit:
/// 1. Emits [OwnerRestaurantUpdateSuccess] — signals the edit screen to show a snackbar and pop
/// 2. Immediately re-fetches and emits [OwnerRestaurantLoaded] with fresh data
class OwnerRestaurantCubit extends Cubit<OwnerRestaurantState> {
  OwnerRestaurantCubit(this._repository)
    : super(const OwnerRestaurantInitial());

  final RestaurantRepository _repository;

  /// Fetches the authenticated owner's restaurant for pre-filling the edit form.
  ///
  /// Emits [OwnerRestaurantLoaded] on success,
  /// [OwnerRestaurantFailure] if the request fails.
  Future<void> fetch() async {
    emit(const OwnerRestaurantLoading());
    try {
      final restaurant = await _repository.getOwn();
      if (isClosed) return;
      emit(OwnerRestaurantLoaded(restaurant));
    } on AppException catch (e) {
      if (isClosed) return;
      emit(OwnerRestaurantFailure(e.message, code: e.code));
    }
  }

  /// Submits a partial update for the owner's restaurant.
  ///
  /// Does not emit [OwnerRestaurantLoading] — the screen uses a local
  /// `_isSubmitting` flag so the form stays in the tree on failure.
  ///
  /// Emits [OwnerRestaurantUpdateSuccess] followed by [OwnerRestaurantLoaded],
  /// or [OwnerRestaurantUpdateFailure] on error.
  Future<void> update(UpdateRestaurantRequest request) async {
    try {
      await _repository.updateOwn(request);
      if (isClosed) return;
      emit(const OwnerRestaurantUpdateSuccess());
      final restaurant = await _repository.getOwn();
      if (isClosed) return;
      emit(OwnerRestaurantLoaded(restaurant));
    } on AppException catch (e) {
      if (isClosed) return;
      emit(OwnerRestaurantUpdateFailure(e.message, code: e.code, details: e.details));
    }
  }
}
