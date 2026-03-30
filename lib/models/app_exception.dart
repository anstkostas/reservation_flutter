/// Base exception for all API and application errors.
///
/// Thrown by repositories and services when a request fails.
/// Caught by cubits/blocs which emit a failure state with [message].
class AppException implements Exception {
  const AppException({required this.message, required this.statusCode});

  final String message;
  final int statusCode;

  @override
  String toString() => 'AppException($statusCode): $message';
}

/// Thrown when the server returns a 401 Unauthorized response.
///
/// The Dio interceptor catches 401s and dispatches [AuthLogoutRequested]
/// via get_it — this exception is propagated upward so callers can
/// distinguish an auth failure from a generic API error.
class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'Session expired. Please log in again.',
    super.statusCode = 401,
  });
}
