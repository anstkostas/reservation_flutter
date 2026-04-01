import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../models/app_exception.dart';
import '../models/requests/requests.dart';
import 'dio_client.dart';

/// Handles raw HTTP calls for all reservation endpoints.
///
/// Accepts typed request models for mutation endpoints.
/// Returns decoded response data — model construction is [ReservationRepository]'s responsibility.
class ReservationService {
  ReservationService(this._client);

  final DioClient _client;

  /// GET [ApiConstants.myReservations] and return the raw reservation list
  /// for the currently authenticated customer.
  ///
  /// Throws [AppException] on any API or network error.
  Future<List<dynamic>> getMyReservations() async {
    try {
      final response = await _client.dio.get(ApiConstants.myReservations);
      return response.data['data'] as List<dynamic>;
    } on DioException catch (e) {
      throw e.error as AppException;
    }
  }

  /// GET [ApiConstants.ownerReservations] and return the raw reservation list
  /// for the currently authenticated owner's restaurant.
  ///
  /// Throws [AppException] on any API or network error.
  Future<List<dynamic>> getOwnerReservations() async {
    try {
      final response = await _client.dio.get(ApiConstants.ownerReservations);
      return response.data['data'] as List<dynamic>;
    } on DioException catch (e) {
      throw e.error as AppException;
    }
  }

  /// POST [ApiConstants.createReservation] for [restaurantId] with [request] as
  /// the request body. Returns the raw created reservation object.
  ///
  /// Throws [AppException] on any API or network error.
  Future<Map<String, dynamic>> create(
    String restaurantId,
    CreateReservationRequest request,
  ) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.createReservation(restaurantId),
        data: request.toMap(),
      );
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw e.error as AppException;
    }
  }

  /// PUT [ApiConstants.updateReservation] for [id] with [request] as the request body.
  /// Returns the raw updated reservation object.
  ///
  /// Throws [AppException] on any API or network error.
  Future<Map<String, dynamic>> update(
    String id,
    UpdateReservationRequest request,
  ) async {
    try {
      final response = await _client.dio.put(
        ApiConstants.updateReservation(id),
        data: request.toMap(),
      );
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw e.error as AppException;
    }
  }

  /// DELETE [ApiConstants.cancelReservation] for [id].
  /// Soft-cancels the reservation — no row is deleted on the server.
  ///
  /// Throws [AppException] on any API or network error.
  Future<void> cancel(String id) async {
    try {
      await _client.dio.delete(ApiConstants.cancelReservation(id));
    } on DioException catch (e) {
      throw e.error as AppException;
    }
  }

  /// POST [ApiConstants.resolveReservation] for [id] with [request] as the request body.
  /// Returns the raw updated reservation object.
  ///
  /// Throws [AppException] on any API or network error.
  Future<Map<String, dynamic>> resolve(
    String id,
    ResolveReservationRequest request,
  ) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.resolveReservation(id),
        data: request.toMap(),
      );
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw e.error as AppException;
    }
  }
}
