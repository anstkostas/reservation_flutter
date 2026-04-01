import '../models/models.dart';
import '../services/restaurant_service.dart';

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
