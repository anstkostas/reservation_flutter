import 'package:bloc/bloc.dart';
import 'package:logger/logger.dart';

/// Debug-only observer that logs all Cubit and BLoC state transitions and errors.
///
/// Registered in [main] only when [kDebugMode] is `true` — completely absent
/// from release builds, so there is no runtime overhead in production.
///
/// ---
///
/// ## App-wide error handling architecture
///
/// Errors in this app flow through a strict layered chain. Understanding the
/// full chain explains why errors are logged at two points: here at the cubit
/// layer (state transitions) and in each service (network failures).
///
/// ```
/// HTTP response (non-2xx)
///   └─▶ DioClient._onError interceptor
///         ├─ 401  → dispatches AuthLogoutRequested to AuthBloc (global logout)
///         │         wraps error as UnauthorizedException
///         ├─ 4xx/5xx → extracts server message, wraps as AppException(message, statusCode)
///         └─ network / timeout → wraps as AppException('Network error...', statusCode: 0)
///
/// DioException  (with .error already set to AppException by the interceptor)
///   └─▶ Service catch block
///         └─ logs the error  ← Logger.e in AuthService / ReservationService / RestaurantService
///              then rethrows as AppException
///
/// AppException
///   └─▶ Repository  (no catch — exception bubbles through)
///         └─▶ Cubit catch block
///               └─ emits XxxFailure(message)  ← AppBlocObserver.onChange logs this transition
///
/// XxxFailure state
///   └─▶ BlocConsumer listener in the screen widget
///         └─ ScaffoldMessenger.showSnackBar with state.message
/// ```
///
/// The UI never handles raw exceptions — only typed failure states carrying
/// a pre-normalized, human-readable message from the server or a network fallback.
class AppBlocObserver extends BlocObserver {
  AppBlocObserver() : _logger = Logger();

  final Logger _logger;

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    _logger.i('${bloc.runtimeType}: ${change.nextState.runtimeType}');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    _logger.e(
      '${bloc.runtimeType} unhandled error',
      error: error,
      stackTrace: stackTrace,
    );
    super.onError(bloc, error, stackTrace);
  }
}
