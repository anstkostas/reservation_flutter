import 'package:antigravity_client/models/models.dart';
import 'package:antigravity_client/services/restaurant_service.dart';

/// Maps raw restaurant API responses to typed models.
///
/// Callers receive [RestaurantModel] instances — this layer owns the
/// deserialization. Exceptions from [RestaurantService] propagate upward
/// without being caught here:
/// - [AppException] is caught by the relevant Cubit and emits a failure state
class RestaurantRepository {
  RestaurantRepository(this._service);

  final RestaurantService _service;

  /// Returns all restaurants as a list of [RestaurantModel].
  ///
  /// Throws [AppException] on network error.
  Future<List<RestaurantModel>> getAll() async {
    final data = await _service.getAll();
    return data
        .cast<Map<String, dynamic>>()
        .map(RestaurantModel.fromJson)
        .toList();
  }

  /// Returns the restaurant with [id] as a [RestaurantModel].
  ///
  /// Throws [AppException] on network error or if the restaurant is not found.
  Future<RestaurantModel> getById(String id) async {
    final data = await _service.getById(id);
    return RestaurantModel.fromJson(data);
  }

  /// Returns the authenticated owner's restaurant as a [RestaurantPrivateModel].
  ///
  /// Throws [AppException] on network error or if the owner has no restaurant.
  Future<RestaurantPrivateModel> getOwn() async {
    final data = await _service.getOwn();
    return RestaurantPrivateModel.fromJson(data);
  }

  /// Updates the authenticated owner's restaurant and returns the updated [RestaurantPrivateModel].
  ///
  /// Throws [AppException] on network error or validation failure.
  Future<RestaurantPrivateModel> updateOwn(
    UpdateRestaurantRequest request,
  ) async {
    final data = await _service.updateOwn(request);
    return RestaurantPrivateModel.fromJson(data);
  }

  /// Returns all restaurants without an owner as a list of [RestaurantModel].
  ///
  /// Used in the owner signup flow to let a new owner claim a restaurant.
  /// Throws [AppException] on network error.
  Future<List<RestaurantModel>> getUnowned() async {
    final data = await _service.getUnowned();
    return data
        .cast<Map<String, dynamic>>()
        .map(RestaurantModel.fromJson)
        .toList();
  }
}
