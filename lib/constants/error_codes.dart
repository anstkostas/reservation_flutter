/// Machine-readable error codes — must stay identical to the backend ERROR_CODES
/// object and the React errorCodes constants (same names, same order).
abstract final class ErrorCodes {
  // Auth
  static const String authInvalidCredentials = 'AUTH_INVALID_CREDENTIALS';
  static const String authRefreshInvalid = 'AUTH_REFRESH_INVALID';
  static const String authRefreshReuse = 'AUTH_REFRESH_REUSE';
  static const String authRefreshExpired = 'AUTH_REFRESH_EXPIRED';
  static const String authUserNotFound = 'AUTH_USER_NOT_FOUND';
  static const String authNotAuthenticated = 'AUTH_NOT_AUTHENTICATED';
  static const String authNoToken = 'AUTH_NO_TOKEN';
  static const String authTokenExpired = 'AUTH_TOKEN_EXPIRED';
  static const String authTokenInvalid = 'AUTH_TOKEN_INVALID';
  static const String authNoRefreshToken = 'AUTH_NO_REFRESH_TOKEN';
  static const String authCookieParserMissing = 'AUTH_COOKIE_PARSER_MISSING';

  // Authorization / role
  static const String forbidden = 'FORBIDDEN';
  static const String reservationCustomerOnly = 'RESERVATION_CUSTOMER_ONLY';
  static const String reservationNotOwner = 'RESERVATION_NOT_OWNER';
  static const String reservationOwnerOnly = 'RESERVATION_OWNER_ONLY';
  static const String reservationWrongRestaurant =
      'RESERVATION_WRONG_RESTAURANT';

  // Reservation business rules
  static const String reservationNotFound = 'RESERVATION_NOT_FOUND';
  static const String reservationSlotFull = 'RESERVATION_SLOT_FULL';
  static const String reservationNotActive = 'RESERVATION_NOT_ACTIVE';
  static const String reservationTimeInvalid = 'RESERVATION_TIME_INVALID';
  static const String reservationOwnerNoRestaurant =
      'RESERVATION_OWNER_NO_RESTAURANT';

  // Restaurant
  static const String restaurantNotFound = 'RESTAURANT_NOT_FOUND';

  // User / signup
  static const String userEmailExists = 'USER_EMAIL_EXISTS';
  static const String userOwnerRestaurantRequired =
      'USER_OWNER_RESTAURANT_REQUIRED';
  static const String restaurantAlreadyOwned = 'RESTAURANT_ALREADY_OWNED';

  // Infrastructure
  static const String resourceConflict = 'RESOURCE_CONFLICT';
  static const String serviceUnavailable = 'SERVICE_UNAVAILABLE';
  static const String internalError = 'INTERNAL_ERROR';
  static const String validationError = 'VALIDATION_ERROR';
}
