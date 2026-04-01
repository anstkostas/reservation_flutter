import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';

import '../cubits/auth/auth_bloc.dart';
import '../models/models.dart';
import 'cookie_setup/cookie_setup.dart';

/// The single HTTP client for all API calls.
///
/// Must be initialized via [initialize] before any API method is called.
/// [initialize] is async because cookie setup requires file system access
/// on mobile. Register this as a lazy singleton in get_it and await
/// [initialize] during service locator setup.
///
/// Usage:
/// ```dart
/// final client = DioClient();
/// await client.initialize();
/// ```
class DioClient {
  DioClient() {
    _dio = Dio();
  }

  late final Dio _dio;

  /// Exposes the configured [Dio] instance to API services.
  Dio get dio => _dio;

  /// Configures base URL, cookie interceptor, and error normalization.
  ///
  /// Must be awaited before any request is made. Called once during
  /// service locator setup in [main].
  Future<void> initialize() async {
    final baseUrl = dotenv.env['API_BASE_URL'];
    assert(
      baseUrl != null && baseUrl.isNotEmpty,
      'API_BASE_URL is not set in .env — DioClient cannot initialize.',
    );

    _dio.options = BaseOptions(
      baseUrl: baseUrl!,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      // Web: tells the browser to include cookies in cross-origin requests.
      // Mobile: ignored by the native HTTP adapter.
      extra: {'withCredentials': true},
    );

    final cookieInterceptor = await buildCookieInterceptor();
    if (cookieInterceptor != null) {
      _dio.interceptors.add(cookieInterceptor);
    }

    _dio.interceptors.add(InterceptorsWrapper(onError: _onError));
  }

  /// Normalizes all non-2xx Dio errors into [AppException] or [UnauthorizedException].
  ///
  /// The exception is stored in [DioException.error] so that services
  /// can extract and rethrow it via `e.error as AppException`.
  void _onError(DioException e, ErrorInterceptorHandler handler) {
    final statusCode = e.response?.statusCode;

    if (statusCode == 401) {
      // Dispatch to AuthBloc so any 401 — from any endpoint — logs the user
      // out and transitions the UI to the login screen. get_it is used here
      // because the interceptor has no BuildContext or BlocProvider access.
      // AuthBloc is a lazy singleton guaranteed to exist before any request fires.
      GetIt.instance<AuthBloc>().add(const AuthLogoutRequested());
      handler.reject(
        DioException(
          requestOptions: e.requestOptions,
          response: e.response,
          type: e.type,
          error: const UnauthorizedException(),
        ),
      );
      return;
    }

    if (e.response != null) {
      final data = e.response!.data;
      final message = data is Map<String, dynamic>
          ? (data['message'] as String?) ?? 'An error occurred.'
          : 'An error occurred.';

      handler.reject(
        DioException(
          requestOptions: e.requestOptions,
          response: e.response,
          type: e.type,
          error: AppException(message: message, statusCode: statusCode ?? 500),
        ),
      );
      return;
    }

    // Network errors, timeouts, DNS failures, etc.
    handler.reject(
      DioException(
        requestOptions: e.requestOptions,
        response: e.response,
        type: e.type,
        error: const AppException(
          message: 'Network error. Please check your connection.',
          statusCode: 0,
        ),
      ),
    );
  }
}
