import 'package:flutter/material.dart';

import '../constants/error_codes.dart';
import '../l10n/app_localizations.dart';

/// Returns the localized string for [code], or falls back to [message]
/// (the backend's English string) when no translation key exists.
///
/// This is the Flutter analog of React's `t(key) !== key` fallback — the switch
/// is explicit over [ErrorCodes] constants so the analyzer can verify coverage
/// and a new code without a case is caught at code review, not at runtime.
String resolveErrorMessage(
  BuildContext context, {
  required String message,
  String? code,
}) {
  if (code == null) return message;
  final l10n = AppLocalizations.of(context)!;
  return switch (code) {
    ErrorCodes.authInvalidCredentials => l10n.errorAuthInvalidCredentials,
    ErrorCodes.authRefreshInvalid => l10n.errorAuthRefreshInvalid,
    ErrorCodes.authRefreshReuse => l10n.errorAuthRefreshReuse,
    ErrorCodes.authRefreshExpired => l10n.errorAuthRefreshExpired,
    ErrorCodes.authUserNotFound => l10n.errorAuthUserNotFound,
    ErrorCodes.authNotAuthenticated => l10n.errorAuthNotAuthenticated,
    ErrorCodes.authNoToken => l10n.errorAuthNoToken,
    ErrorCodes.authTokenExpired => l10n.errorAuthTokenExpired,
    ErrorCodes.authTokenInvalid => l10n.errorAuthTokenInvalid,
    ErrorCodes.authNoRefreshToken => l10n.errorAuthNoRefreshToken,
    ErrorCodes.forbidden => l10n.errorForbidden,
    ErrorCodes.reservationCustomerOnly => l10n.errorReservationCustomerOnly,
    ErrorCodes.reservationNotOwner => l10n.errorReservationNotOwner,
    ErrorCodes.reservationOwnerOnly => l10n.errorReservationOwnerOnly,
    ErrorCodes.reservationWrongRestaurant =>
      l10n.errorReservationWrongRestaurant,
    ErrorCodes.reservationNotFound => l10n.errorReservationNotFound,
    ErrorCodes.reservationSlotFull => l10n.errorReservationSlotFull,
    ErrorCodes.reservationNotActive => l10n.errorReservationNotActive,
    ErrorCodes.reservationTimeInvalid => l10n.errorReservationTimeInvalid,
    ErrorCodes.reservationOwnerNoRestaurant =>
      l10n.errorReservationOwnerNoRestaurant,
    ErrorCodes.restaurantNotFound => l10n.errorRestaurantNotFound,
    ErrorCodes.userEmailExists => l10n.errorUserEmailExists,
    ErrorCodes.userOwnerRestaurantRequired =>
      l10n.errorUserOwnerRestaurantRequired,
    ErrorCodes.restaurantAlreadyOwned => l10n.errorRestaurantAlreadyOwned,
    ErrorCodes.resourceConflict => l10n.errorResourceConflict,
    ErrorCodes.validationError => l10n.errorValidationError,
    // AUTH_COOKIE_PARSER_MISSING, SERVICE_UNAVAILABLE, INTERNAL_ERROR — no ARB
    // key (infra/misconfig codes); fall back to the backend's English message.
    _ => message,
  };
}
