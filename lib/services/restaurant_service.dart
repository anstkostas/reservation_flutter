import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../models/app_exception.dart';
import 'dio_client.dart';

/// Handles raw HTTP calls for all restaurant endpoints.
///
/// Returns decoded response data — model construction is [RestaurantRepository]'s responsibility.
class RestaurantService {
  RestaurantService(this._client);

  final DioClient _client;

  /// GET [ApiConstants.restaurants] and return the raw restaurant list.
  ///
  /// Throws [AppException] on any API or network error.
  Future<List<dynamic>> getAll() async {
    try {
      final response = await _client.dio.get(ApiConstants.restaurants);
      return response.data['data'] as List<dynamic>;
    } on DioException catch (e) {
      throw e.error as AppException;
    }
  }

  /// GET [ApiConstants.restaurantById] and return the raw restaurant object.
  ///
  /// Throws [AppException] on any API or network error.
  Future<Map<String, dynamic>> getById(String id) async {
    try {
      final response = await _client.dio.get(ApiConstants.restaurantById(id));
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw e.error as AppException;
    }
  }

  /// GET [ApiConstants.unownedRestaurants] and return the raw list of restaurants
  /// with no owner — used in the owner signup flow.
  ///
  /// Throws [AppException] on any API or network error.
  Future<List<dynamic>> getUnowned() async {
    try {
      final response = await _client.dio.get(ApiConstants.unownedRestaurants);
      return response.data['data'] as List<dynamic>;
    } on DioException catch (e) {
      throw e.error as AppException;
    }
  }
}
