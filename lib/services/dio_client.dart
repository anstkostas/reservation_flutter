import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';

import '../constants/api_constants.dart';
import '../cubits/auth/auth_bloc.dart';
import '../models/models.dart';
import 'cookie_setup/cookie_setup.dart' as cookie_setup;

/// Single HTTP client for the app — all API calls go through this.
///
/// ## Lifecycle
///
/// 1. Construct: `final client = DioClient();` (synchronous).
/// 2. Initialize: `await client.initialize();` (asynchronous — cookie setup
///    on mobile needs file system access).
/// 3. Register in `get_it` as a `lazySingleton`; await `initialize()` inside
///    `service_locator` setup before any dependent service is constructed.
///
/// `lazySingleton` (not eager `singleton`) because [initialize] must be
/// awaited — an eager registration would create the instance before its async
/// setup could finish.
///
/// ## Interceptors (added in [initialize], in order)
///
/// 1. **Cookie interceptor** — mobile only; persists auth cookies to disk so
///    the session survives app restarts. Web returns `null` from the factory
///    and is skipped (the browser handles `Set-Cookie` natively).
/// 2. **Error interceptor** — runs on every error response. Routes through
///    [_onError], which either silently refreshes the session (for 401s) or
///    normalises every other failure into [AppException].
///
/// ## Error contract
///
/// Every error reaching the layers above this client is an [AppException]
/// stored in [DioException.error]. The repository layer unwraps it and
/// re-throws. Callers never read raw Dio status codes or response bodies.
///
/// - Network / DNS / timeout failures → `AppException(statusCode: 0)`.
/// - HTTP 4xx / 5xx → `AppException` carrying the backend's `message` and
///   the actual status code.
/// - HTTP 401 (auth endpoints, or non-auth after refresh fails) →
///   [UnauthorizedException]. Subclass of [AppException] so type-based
///   `catch` clauses can distinguish session loss from other failures.
///
/// ## Coupling to AuthBloc
///
/// On refresh failure this client dispatches `AuthLogoutRequested` on
/// `AuthBloc` via `get_it`. The interceptor sits outside the widget tree and
/// has no `BuildContext` — `context.read<AuthBloc>()` is not available here.
/// `get_it` is the only way to reach the exact same `AuthBloc` instance that
/// drives the UI and `GoRouterRefreshStream`.
///
/// This creates a documented `DioClient ↔ AuthBloc` circular dependency,
/// resolved at runtime by initialization order in `service_locator`. Do not
/// change that order.
///
/// ## Usage
///
/// ```dart
/// final client = DioClient();
/// await client.initialize();
/// // ...later, via get_it:
/// final dio = getIt<DioClient>().dio;
/// final response = await dio.get(ApiConstants.restaurants);
/// ```
class DioClient {
  DioClient() {
    _dio = Dio();
  }

  late final Dio _dio;

  /// Synchronous gate for the concurrent-401 lock. The first 401 to arrive
  /// sees this `false` and becomes the *leader* — it sets this to `true`,
  /// creates [_refreshCompleter], and starts the refresh. Subsequent 401s see
  /// `true` and become *followers* — they suspend on [_refreshCompleter]
  /// instead of starting their own refresh. Reset to `false` immediately
  /// after the refresh settles. See [_onError] for the full flow.
  bool _isRefreshing = false;

  /// Rendezvous primitive followers await while the leader's refresh is in
  /// flight. Created by the leader at the start of each refresh, completed
  /// with the outcome (`true` = refresh succeeded, `false` = refresh failed),
  /// then nulled out. See [_onError] for the full flow.
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

    final cookieInterceptor = await cookie_setup.buildCookieInterceptor();
    if (cookieInterceptor != null) {
      _dio.interceptors.add(cookieInterceptor);
    }

    _dio.interceptors.add(InterceptorsWrapper(onError: _onError));
  }

  /// Clears the persistent cookie jar (mobile only; no-op on web).
  ///
  /// Delegates to the platform-conditional [cookie_setup.clearCookies].
  /// Called after logout so stale auth cookies do not survive the session.
  Future<void> clearCookies() => cookie_setup.clearCookies();

  /// Error interceptor — routes every Dio failure to its appropriate handler.
  ///
  /// ## Paths
  ///
  /// 1. **Non-401** → [_rejectWithAppException]. Normalises the failure into
  ///    an [AppException] and propagates. Most errors take this path.
  /// 2. **401 on auth endpoints** (`/auth/login`, `/auth/signup`,
  ///    `/auth/refresh`, `/auth/logout`) → fast-reject with
  ///    [UnauthorizedException]. These 401s are *intentional* ("wrong
  ///    password", "no valid refresh token"); attempting to silently refresh
  ///    would recurse forever.
  /// 3. **401 elsewhere, refresh already in flight** → suspend on
  ///    [_refreshCompleter] until the in-flight refresh settles. See
  ///    "Concurrent 401 lock" below.
  /// 4. **401 elsewhere, no refresh in flight** → become the *leader*; start
  ///    a refresh (`POST /auth/refresh`), then replay the original request on
  ///    success or dispatch logout on failure.
  ///
  /// ## Silent refresh
  ///
  /// A 401 on a non-auth endpoint usually means the access-token cookie
  /// expired. Rather than propagate the 401, this method calls
  /// `/auth/refresh` (which uses the refresh-token cookie to set a new
  /// access-token cookie), then replays the original request. From every
  /// layer above — service, repository, cubit — a successful refresh is
  /// **invisible**; the request just appears to work.
  ///
  /// ## Concurrent 401 lock
  ///
  /// When the screen fires several requests in parallel and all return 401,
  /// only **one** of them should refresh — the rest must wait and then replay
  /// or fail in unison. Without coordination, parallel `/auth/refresh` calls
  /// would race the backend's refresh-token rotation: the second call would
  /// use an already-invalidated token, fail, and the user would be logged out
  /// even though refresh #1 succeeded.
  ///
  /// Two fields coordinate this:
  /// - [_isRefreshing] — synchronous gate distinguishing leader from
  ///   follower without an `await`.
  /// - [_refreshCompleter] — rendezvous future; the leader completes it with
  ///   the refresh outcome, every follower awakens at once.
  ///
  /// On refresh **success**: leader and followers each replay their own
  /// original request and resolve with the fresh response. The screen sees N
  /// successful responses; the 401s were invisible.
  ///
  /// On refresh **failure**: the leader dispatches `AuthLogoutRequested`
  /// exactly once (global side effect — dispatching from each follower would
  /// emit the auth state change N times). Every parked request — leader and
  /// followers — rejects with [UnauthorizedException]. The cubit layer
  /// catches the typed exception; the routing layer reacts to the auth state
  /// change.
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

  /// Normalises non-401 Dio errors into an [AppException] for callers.
  ///
  /// Two cases:
  /// - **Server responded with an error** (4xx / 5xx) → builds an
  ///   [AppException] from the backend's `{ success: false, message,
  ///   statusCode }` envelope. Falls back to a generic message if the body
  ///   isn't a `Map` or has no `message` field, and to status 500 if the
  ///   response somehow lacks a status code.
  /// - **No server response** (DNS failure, timeout, offline) → builds an
  ///   [AppException] with `statusCode: 0` (sentinel for "no HTTP involved")
  ///   and a friendly fallback message — the raw Dio message is not user
  ///   readable.
  ///
  /// In both cases the [AppException] is wrapped inside a fresh
  /// [DioException] (Dio's `handler.reject` only accepts a `DioException`)
  /// and stored in its [DioException.error] slot. The repository layer reads
  /// `.error` and re-throws the typed exception, so layers above this client
  /// never touch Dio types directly.
  void _rejectWithAppException(
    DioException e,
    ErrorInterceptorHandler handler,
  ) {
    if (e.response != null) {
      final data = e.response!.data;
      final body = data is Map<String, dynamic> ? data : null;
      final message = (body?['message'] as String?) ?? 'An error occurred.';
      final code = body?['code'] as String?;
      handler.reject(
        DioException(
          requestOptions: e.requestOptions,
          response: e.response,
          type: e.type,
          error: AppException(
            message: message,
            statusCode: e.response!.statusCode ?? 500,
            code: code,
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
