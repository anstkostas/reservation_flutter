// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Antigravity';

  @override
  String get navRestaurants => 'Restaurants';

  @override
  String get navLogIn => 'Log in';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navMyRestaurant => 'My Restaurant';

  @override
  String get navReservations => 'Reservations';

  @override
  String get navLogout => 'Logout';

  @override
  String get splashHeadline => 'Reservation App';

  @override
  String get splashSubtitle =>
      'Book, manage, and explore your favorite restaurants seamlessly.';

  @override
  String get splashCtaExplore => 'Explore Restaurants';

  @override
  String get splashCtaDashboard => 'Dashboard';

  @override
  String get splashCtaMyReservations => 'My Reservations';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to your account';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginEmailHint => 'you@example.com';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginSubmitButton => 'Sign in';

  @override
  String get loginNoAccount => 'Don\'t have an account?';

  @override
  String get loginSignUpLink => 'Sign up';

  @override
  String get signupTitle => 'Create account';

  @override
  String get signupSubtitle => 'Fill in the details below to get started';

  @override
  String get signupFirstNameLabel => 'First name';

  @override
  String get signupLastNameLabel => 'Last name';

  @override
  String get signupEmailLabel => 'Email';

  @override
  String get signupEmailHint => 'you@example.com';

  @override
  String get signupPasswordLabel => 'Password';

  @override
  String get signupRolePrompt => 'I am signing up as a:';

  @override
  String get signupRoleCustomer => 'Customer';

  @override
  String get signupRoleOwner => 'Restaurant owner';

  @override
  String get signupSubmitButton => 'Create account';

  @override
  String get signupHaveAccount => 'Already have an account?';

  @override
  String get signupSignInLink => 'Sign in';

  @override
  String get signupRestaurantPickerLabel => 'Select your restaurant';

  @override
  String get signupRestaurantPickerRequired => 'Select a restaurant to claim';

  @override
  String get signupNoRestaurantsAvailable =>
      'No restaurants available to claim. Sign up as a customer instead.';

  @override
  String get signupRetry => 'Retry';

  @override
  String get restaurantListTitle => 'Available Restaurants';

  @override
  String get restaurantListEmpty => 'No restaurants available.';

  @override
  String restaurantCardCapacity(int capacity) {
    return 'Capacity: $capacity Tables';
  }

  @override
  String get restaurantCardViewButton => 'View Details & Book';

  @override
  String get restaurantDetailAbout => 'About';

  @override
  String get restaurantDetailAddress => 'Address';

  @override
  String get restaurantDetailPhone => 'Phone';

  @override
  String restaurantDetailCapacityChip(int capacity) {
    return 'Capacity: $capacity Tables';
  }

  @override
  String get restaurantDetailMakeReservationTitle => 'Make a Reservation';

  @override
  String get restaurantDetailMakeReservationSubtitle =>
      'Secure your table for an unforgettable dining experience.';

  @override
  String get restaurantDetailBookButton => 'Book a Table';

  @override
  String get reservationHistoryTitle => 'My Reservations';

  @override
  String get reservationHistorySubtitle =>
      'View and manage your dining bookings.';

  @override
  String get reservationHistoryBookButton => 'Book a Table';

  @override
  String reservationHistoryTabUpcoming(int count) {
    return 'Upcoming ($count)';
  }

  @override
  String reservationHistoryTabHistory(int count) {
    return 'History ($count)';
  }

  @override
  String get reservationHistoryEmptyUpcomingTitle => 'No upcoming reservations';

  @override
  String get reservationHistoryEmptyUpcomingDetail =>
      'You don\'t have any active bookings at the moment. Explore restaurants and book your next meal!';

  @override
  String get reservationHistoryEmptyPastTitle => 'No past reservations';

  @override
  String get reservationHistoryEmptyPastDetail => 'No reservation history yet.';

  @override
  String get reservationUpdatedSnackbar => 'Reservation updated.';

  @override
  String get ownerDashboardTitle => 'Dashboard';

  @override
  String get ownerDashboardSubtitle =>
      'Manage your restaurant\'s reservations.';

  @override
  String ownerDashboardTabActive(int count) {
    return 'Active ($count)';
  }

  @override
  String ownerDashboardTabHistory(int count) {
    return 'History ($count)';
  }

  @override
  String get ownerDashboardSearchHint => 'Search by name or email...';

  @override
  String get ownerDashboardNoReservations => 'No reservations found.';

  @override
  String get ownerResolvedSnackbar => 'Reservation resolved.';

  @override
  String get ownerTableColumnCustomer => 'Customer';

  @override
  String get ownerTableColumnDate => 'Date';

  @override
  String get ownerTableColumnTime => 'Time';

  @override
  String get ownerTableColumnPeople => 'People';

  @override
  String get ownerTableColumnStatus => 'Status';

  @override
  String get ownerTableColumnActions => 'Actions';

  @override
  String get ownerTableMarkCompleted => 'Mark as completed';

  @override
  String get ownerTableMarkNoShow => 'Mark as no-show';

  @override
  String get ownerTableArrivingSoon => 'Arriving soon';

  @override
  String get ownerMobileComplete => 'Complete';

  @override
  String get ownerMobileNoShow => 'No-show';

  @override
  String ownerMobilePeopleLabel(int count) {
    return '$count People';
  }

  @override
  String get reservationCreateTitle => 'Make a Reservation';

  @override
  String get reservationCreateDateLabel => 'Date';

  @override
  String get reservationCreateTimeLabel => 'Time';

  @override
  String get reservationCreateGuestsLabel => 'Number of guests';

  @override
  String get reservationCreateConfirmButton => 'Confirm';

  @override
  String get reservationCreateSelectDate => 'Select a date';

  @override
  String get reservationCreateSelectTime => 'Select a time';

  @override
  String get reservationCreateSuccess => 'Reservation confirmed!';

  @override
  String get reservationEditTitle => 'Edit Reservation';

  @override
  String get reservationEditDateLabel => 'Date';

  @override
  String get reservationEditTimeLabel => 'Time';

  @override
  String get reservationEditGuestsLabel => 'Number of guests';

  @override
  String get reservationEditDiscardButton => 'Discard';

  @override
  String get reservationEditSaveButton => 'Save changes';

  @override
  String get reservationEditSelectDate => 'Select a date';

  @override
  String get reservationEditSelectTime => 'Select a time';

  @override
  String get reservationCancelDialogTitle => 'Cancel reservation?';

  @override
  String get reservationCancelDialogContent => 'This cannot be undone.';

  @override
  String get reservationCancelDialogKeep => 'Keep it';

  @override
  String get reservationCancelDialogConfirm => 'Cancel reservation';

  @override
  String get reservationDetailEditButton => 'Edit';

  @override
  String get reservationDetailCancelButton => 'Cancel';

  @override
  String get reservationDetailGuestSingular => '1 guest';

  @override
  String reservationDetailGuestPlural(int count) {
    return '$count guests';
  }

  @override
  String get reservationDetailRestaurantFallback => 'Restaurant';

  @override
  String get reservationCardRestaurantFallback => 'Restaurant';

  @override
  String get statusActive => 'Active';

  @override
  String get statusCanceled => 'Canceled';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusNoShow => 'No-show';

  @override
  String get errorRetry => 'Retry';

  @override
  String get validatorEmailRequired => 'Email is required';

  @override
  String get validatorEmailInvalid => 'Enter a valid email address';

  @override
  String get validatorPasswordRequired => 'Password is required';

  @override
  String get validatorPasswordTooShort =>
      'Password must be at least 6 characters';

  @override
  String validatorFieldRequired(String fieldName) {
    return '$fieldName is required';
  }

  @override
  String get validatorGuestsRequired => 'Number of guests is required';

  @override
  String get validatorGuestsInvalidNumber => 'Enter a valid number';

  @override
  String get validatorGuestsTooFew => 'Must be at least 1 guest';

  @override
  String get validatorGuestsTooMany => 'Cannot exceed 20 guests';

  @override
  String get languageSelectorEnglish => 'English';

  @override
  String get languageSelectorGreek => 'Greek';

  @override
  String get errorAuthInvalidCredentials => 'Invalid email or password';

  @override
  String get errorAuthRefreshInvalid =>
      'Your session is invalid. Please sign in again.';

  @override
  String get errorAuthRefreshReuse =>
      'Security alert: your session was used from another device. All sessions have been ended.';

  @override
  String get errorAuthRefreshExpired =>
      'Your session has expired. Please sign in again.';

  @override
  String get errorAuthUserNotFound => 'User not found. Please sign in again.';

  @override
  String get errorAuthNotAuthenticated => 'Please sign in to continue.';

  @override
  String get errorAuthNoToken => 'Authentication required.';

  @override
  String get errorAuthTokenExpired =>
      'Your session has expired. Please sign in again.';

  @override
  String get errorAuthTokenInvalid => 'Invalid session. Please sign in again.';

  @override
  String get errorAuthNoRefreshToken =>
      'No active session found. Please sign in again.';

  @override
  String get errorForbidden => 'You do not have permission to access this.';

  @override
  String get errorReservationCustomerOnly =>
      'Only customers can make or manage reservations.';

  @override
  String get errorReservationNotOwner =>
      'You can only modify your own reservations.';

  @override
  String get errorReservationOwnerOnly =>
      'Only restaurant owners can perform this action.';

  @override
  String get errorReservationWrongRestaurant =>
      'This reservation belongs to a different restaurant.';

  @override
  String get errorReservationNotFound => 'Reservation not found.';

  @override
  String get errorReservationSlotFull =>
      'This time slot is fully booked. Please choose another time.';

  @override
  String get errorReservationNotActive =>
      'Only active reservations can be modified or canceled.';

  @override
  String get errorReservationTimeInvalid =>
      'Please choose a valid time within the booking window.';

  @override
  String get errorReservationOwnerNoRestaurant =>
      'Your account has no restaurant assigned.';

  @override
  String get ownerEditRestaurantButton => 'Edit Restaurant';

  @override
  String get restaurantEditTitle => 'Edit Restaurant';

  @override
  String get restaurantEditSubtitle => 'Update your restaurant details.';

  @override
  String get restaurantEditNameLabel => 'Name';

  @override
  String get restaurantEditDescriptionEnLabel => 'Description (English)';

  @override
  String get restaurantEditDescriptionElLabel => 'Description (Greek)';

  @override
  String get restaurantEditAddressLabel => 'Address';

  @override
  String get restaurantEditPhoneLabel => 'Phone';

  @override
  String get restaurantEditCapacityLabel => 'Capacity (tables)';

  @override
  String get restaurantEditSaveButton => 'Save changes';

  @override
  String get restaurantEditSuccessSnackbar => 'Restaurant updated.';

  @override
  String get errorRestaurantNotFound => 'Restaurant not found.';

  @override
  String get errorRestaurantOwnerOnly =>
      'Only restaurant owners can perform this action.';

  @override
  String get errorRestaurantNoneForOwner =>
      'Your account has no restaurant assigned.';

  @override
  String get errorUserEmailExists =>
      'An account with this email already exists.';

  @override
  String get errorUserOwnerRestaurantRequired =>
      'Please select a restaurant to manage.';

  @override
  String get errorRestaurantAlreadyOwned =>
      'This restaurant already has an owner.';

  @override
  String get errorResourceConflict => 'This resource already exists.';

  @override
  String get errorValidationError => 'Please check the form for errors.';
}
