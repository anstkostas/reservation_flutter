import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

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
  final Logger _logger = Logger();

  /// GET [ApiConstants.myReservations] and return the raw reservation list
  /// for the currently authenticated customer.
  ///
  /// Throws [AppException] on any API or network error.
  Future<List<dynamic>> getMyReservations() async {
    try {
      final response = await _client.dio.get(ApiConstants.myReservations);
      return response.data['data'] as List<dynamic>;
    } on DioException catch (e) {
      _logger.e('getMyReservations failed', error: e.error);
      final error = e.error;
      throw error is AppException ? error : const AppException(message: 'Unexpected error', statusCode: 0);
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
      _logger.e('getOwnerReservations failed', error: e.error);
      final error = e.error;
      throw error is AppException ? error : const AppException(message: 'Unexpected error', statusCode: 0);
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
      _logger.e('create reservation failed', error: e.error);
      final error = e.error;
      throw error is AppException ? error : const AppException(message: 'Unexpected error', statusCode: 0);
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
      _logger.e('update reservation failed', error: e.error);
      final error = e.error;
      throw error is AppException ? error : const AppException(message: 'Unexpected error', statusCode: 0);
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
      _logger.e('cancel reservation failed', error: e.error);
      final error = e.error;
      throw error is AppException ? error : const AppException(message: 'Unexpected error', statusCode: 0);
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
      _logger.e('resolve reservation failed', error: e.error);
      final error = e.error;
      throw error is AppException ? error : const AppException(message: 'Unexpected error', statusCode: 0);
    }
  }
}
