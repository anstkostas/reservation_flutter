import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../constants/api_constants.dart';
import '../models/app_exception.dart';
import '../models/requests/requests.dart';
import 'dio_client.dart';

/// Handles raw HTTP calls for all auth endpoints.
///
/// Accepts typed request models — body shape is [LoginRequest] / [SignupRequest]'s responsibility.
/// Returns decoded response data — model construction is [AuthRepository]'s responsibility.
class AuthService {
  AuthService(this._client);

  final DioClient _client;
  final Logger _logger = Logger();

  /// POST [ApiConstants.login] with [request] as the request body.
  ///
  /// Returns the raw `data` field from the response envelope:
  /// `{ "user": {...}, "token": "..." }`.
  ///
  /// Throws [AppException] on any API or network error.
  Future<Map<String, dynamic>> login(LoginRequest request) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.login,
        data: request.toMap(),
      );
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      _logger.e('login failed', error: e.error);
      final error = e.error;
      throw error is AppException ? error : const AppException(message: 'Unexpected error', statusCode: 0);
    }
  }

  /// POST [ApiConstants.signup] with [request] as the request body.
  ///
  /// Returns the raw `data` field from the response envelope:
  /// `{ "user": {...}, "token": "..." }`.
  ///
  /// Throws [AppException] on any API or network error.
  Future<Map<String, dynamic>> signup(SignupRequest request) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.signup,
        data: request.toMap(),
      );
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      _logger.e('signup failed', error: e.error);
      final error = e.error;
      throw error is AppException ? error : const AppException(message: 'Unexpected error', statusCode: 0);
    }
  }

  /// POST [ApiConstants.logout] to clear the server-side auth cookie.
  ///
  /// Throws [AppException] on any API or network error.
  Future<void> logout() async {
    try {
      await _client.dio.post(ApiConstants.logout);
    } on DioException catch (e) {
      _logger.e('logout failed', error: e.error);
      final error = e.error;
      throw error is AppException ? error : const AppException(message: 'Unexpected error', statusCode: 0);
    }
  }

  /// GET [ApiConstants.me] and return the raw user object from the response.
  ///
  /// Throws [UnauthorizedException] if no valid session exists.
  /// Throws [AppException] on any other API or network error.
  Future<Map<String, dynamic>> getMe() async {
    try {
      final response = await _client.dio.get(ApiConstants.me);
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      _logger.e('getMe failed', error: e.error);
      final error = e.error;
      throw error is AppException ? error : const AppException(message: 'Unexpected error', statusCode: 0);
    }
  }
}
