import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';

import '../constants/api_constants.dart';
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
  bool _isRefreshing = false;
  Completer<bool>? _refreshCompleter;

  /// Exposes the configured [Dio] instance to API services.
  Dio get dio => _dio;

  /// Configures base URL, cookie interceptor, and error normalization.
  ///
  /// Must be awaited before any request is made. Called once during
  /// service locator setup in [main].
  Future<void> initialize() async {
    final baseUrl = dotenv.env['API_BASE_URL'];
    if (baseUrl == null || baseUrl.isEmpty) {
      throw StateError(
        'API_BASE_URL is not set in .env — DioClient cannot initialize.',
      );
    }

    _dio.options = BaseOptions(
      baseUrl: baseUrl,
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

  /// On 401, attempts a silent token refresh before rejecting.
  /// Auth endpoints always reject immediately — their 401s are intentional.
  /// Concurrent 401s share one refresh call via a Completer lock.
  Future<void> _onError(DioException e, ErrorInterceptorHandler handler) async {
    final statusCode = e.response?.statusCode;

    if (statusCode != 401) {
      _rejectWithAppException(e, handler);
      return;
    }

    // Skip refresh for auth endpoints — they produce intentional 401s
    final path = e.requestOptions.path;
    final isAuthEndpoint =
        path.contains('/auth/login') ||
        path.contains('/auth/signup') ||
        path.contains('/auth/refresh') ||
        path.contains('/auth/logout');

    if (isAuthEndpoint) {
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

    // Refresh lock — queue concurrent 401s behind a single refresh call
    if (_isRefreshing) {
      final refreshed = await _refreshCompleter!.future;
      if (refreshed) {
        try {
          final retried = await _dio.fetch(e.requestOptions);
          handler.resolve(retried);
        } catch (_) {
          handler.reject(e);
        }
      } else {
        handler.reject(
          DioException(
            requestOptions: e.requestOptions,
            response: e.response,
            type: e.type,
            error: const UnauthorizedException(),
          ),
        );
      }
      return;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();

    try {
      await _dio.post(ApiConstants.refresh);
      _refreshCompleter!.complete(true);
      _isRefreshing = false;
      _refreshCompleter = null;

      try {
        final retried = await _dio.fetch(e.requestOptions);
        handler.resolve(retried);
      } catch (_) {
        handler.reject(e);
      }
    } catch (_) {
      _refreshCompleter!.complete(false);
      _isRefreshing = false;
      _refreshCompleter = null;

      GetIt.instance<AuthBloc>().add(const AuthLogoutRequested());
      handler.reject(
        DioException(
          requestOptions: e.requestOptions,
          response: e.response,
          type: e.type,
          error: const UnauthorizedException(),
        ),
      );
    }
  }

  /// Normalizes non-401 Dio errors into [AppException] stored in [DioException.error].
  void _rejectWithAppException(
    DioException e,
    ErrorInterceptorHandler handler,
  ) {
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
          error: AppException(
            message: message,
            statusCode: e.response!.statusCode ?? 500,
          ),
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
