import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_el.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('el'),
    Locale('en'),
  ];

  /// App name shown in the browser tab and loading screen
  ///
  /// In en, this message translates to:
  /// **'Antigravity'**
  String get appTitle;

  /// Navigation bar link to the restaurant listing page
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get navRestaurants;

  /// Navigation bar link to the login page — shown when the user is not authenticated
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get navLogIn;

  /// Navigation bar link to the owner dashboard — shown to restaurant owners only
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// Navigation bar link to the reservation history page — shown to customers only
  ///
  /// In en, this message translates to:
  /// **'Reservations'**
  String get navReservations;

  /// Navigation bar logout button — shown when the user is authenticated
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get navLogout;

  /// Large headline on the splash/landing screen
  ///
  /// In en, this message translates to:
  /// **'Reservation App'**
  String get splashHeadline;

  /// Subtitle on the splash/landing screen describing the app purpose
  ///
  /// In en, this message translates to:
  /// **'Book, manage, and explore your favorite restaurants seamlessly.'**
  String get splashSubtitle;

  /// Call-to-action button on the splash screen — navigates to the restaurant list; shown to unauthenticated users and customers
  ///
  /// In en, this message translates to:
  /// **'Explore Restaurants'**
  String get splashCtaExplore;

  /// Call-to-action button on the splash screen — navigates to the owner dashboard; shown to restaurant owners only
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get splashCtaDashboard;

  /// Call-to-action button on the splash screen — navigates to reservation history; shown to customers only
  ///
  /// In en, this message translates to:
  /// **'My Reservations'**
  String get splashCtaMyReservations;

  /// Heading on the login page
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginTitle;

  /// Subtitle on the login page
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account'**
  String get loginSubtitle;

  /// Label for the email input field on the login form
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmailLabel;

  /// Placeholder text inside the email input field on the login form
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get loginEmailHint;

  /// Label for the password input field on the login form
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// Submit button on the login form
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginSubmitButton;

  /// Text prompting users without an account to sign up — appears next to loginSignUpLink
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get loginNoAccount;

  /// Tappable link text that navigates to the sign-up page — appears next to loginNoAccount
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get loginSignUpLink;

  /// Heading on the sign-up page
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signupTitle;

  /// Subtitle on the sign-up page
  ///
  /// In en, this message translates to:
  /// **'Fill in the details below to get started'**
  String get signupSubtitle;

  /// Label for the first name input field on the sign-up form
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get signupFirstNameLabel;

  /// Label for the last name input field on the sign-up form
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get signupLastNameLabel;

  /// Label for the email input field on the sign-up form
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get signupEmailLabel;

  /// Placeholder text inside the email input field on the sign-up form
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get signupEmailHint;

  /// Label for the password input field on the sign-up form
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get signupPasswordLabel;

  /// Prompt asking the user to select their account type on the sign-up form
  ///
  /// In en, this message translates to:
  /// **'I am signing up as a:'**
  String get signupRolePrompt;

  /// Role option on the sign-up form — selects the customer account type
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get signupRoleCustomer;

  /// Role option on the sign-up form — selects the restaurant owner account type
  ///
  /// In en, this message translates to:
  /// **'Restaurant owner'**
  String get signupRoleOwner;

  /// Submit button on the sign-up form
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signupSubmitButton;

  /// Text prompting users who already have an account to sign in — appears next to signupSignInLink
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get signupHaveAccount;

  /// Tappable link text that navigates to the login page — appears next to signupHaveAccount
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signupSignInLink;

  /// Label for the restaurant selector dropdown shown to users signing up as restaurant owners
  ///
  /// In en, this message translates to:
  /// **'Select your restaurant'**
  String get signupRestaurantPickerLabel;

  /// Validation error shown when an owner signs up without selecting a restaurant
  ///
  /// In en, this message translates to:
  /// **'Select a restaurant to claim'**
  String get signupRestaurantPickerRequired;

  /// Message shown when there are no unclaimed restaurants available for owner sign-up
  ///
  /// In en, this message translates to:
  /// **'No restaurants available to claim. Sign up as a customer instead.'**
  String get signupNoRestaurantsAvailable;

  /// Button to retry loading the restaurant list on the sign-up page after an error
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get signupRetry;

  /// Page heading on the restaurant listing page
  ///
  /// In en, this message translates to:
  /// **'Available Restaurants'**
  String get restaurantListTitle;

  /// Message shown when no restaurants are available on the listing page
  ///
  /// In en, this message translates to:
  /// **'No restaurants available.'**
  String get restaurantListEmpty;

  /// Capacity chip on a restaurant card — capacity is the number of simultaneous table slots
  ///
  /// In en, this message translates to:
  /// **'Capacity: {capacity} Tables'**
  String restaurantCardCapacity(int capacity);

  /// Button on a restaurant card that navigates to the restaurant detail and booking page
  ///
  /// In en, this message translates to:
  /// **'View Details & Book'**
  String get restaurantCardViewButton;

  /// Section heading on the restaurant detail page introducing the restaurant description
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get restaurantDetailAbout;

  /// Capacity chip on the restaurant detail page — capacity is the number of simultaneous table slots
  ///
  /// In en, this message translates to:
  /// **'Capacity: {capacity} Tables'**
  String restaurantDetailCapacityChip(int capacity);

  /// Section heading on the restaurant detail page for the booking form
  ///
  /// In en, this message translates to:
  /// **'Make a Reservation'**
  String get restaurantDetailMakeReservationTitle;

  /// Subtitle below the booking section heading on the restaurant detail page
  ///
  /// In en, this message translates to:
  /// **'Secure your table for an unforgettable dining experience.'**
  String get restaurantDetailMakeReservationSubtitle;

  /// Button on the restaurant detail page that opens the reservation creation sheet
  ///
  /// In en, this message translates to:
  /// **'Book a Table'**
  String get restaurantDetailBookButton;

  /// Page heading on the customer reservation history page
  ///
  /// In en, this message translates to:
  /// **'My Reservations'**
  String get reservationHistoryTitle;

  /// Subtitle on the customer reservation history page
  ///
  /// In en, this message translates to:
  /// **'View and manage your dining bookings.'**
  String get reservationHistorySubtitle;

  /// Button on the reservation history page that navigates to the restaurant list to book a new table
  ///
  /// In en, this message translates to:
  /// **'Book a Table'**
  String get reservationHistoryBookButton;

  /// Tab label for upcoming/active reservations — count is the number of active reservations
  ///
  /// In en, this message translates to:
  /// **'Upcoming ({count})'**
  String reservationHistoryTabUpcoming(int count);

  /// Tab label for past reservations — count is the number of past reservations
  ///
  /// In en, this message translates to:
  /// **'History ({count})'**
  String reservationHistoryTabHistory(int count);

  /// Heading shown when the customer has no upcoming reservations
  ///
  /// In en, this message translates to:
  /// **'No upcoming reservations'**
  String get reservationHistoryEmptyUpcomingTitle;

  /// Detail text shown when the customer has no upcoming reservations
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any active bookings at the moment. Explore restaurants and book your next meal!'**
  String get reservationHistoryEmptyUpcomingDetail;

  /// Heading shown when the customer has no past reservations
  ///
  /// In en, this message translates to:
  /// **'No past reservations'**
  String get reservationHistoryEmptyPastTitle;

  /// Detail text shown when the customer has no past reservations
  ///
  /// In en, this message translates to:
  /// **'No reservation history yet.'**
  String get reservationHistoryEmptyPastDetail;

  /// Snackbar message shown after a reservation is successfully updated
  ///
  /// In en, this message translates to:
  /// **'Reservation updated.'**
  String get reservationUpdatedSnackbar;

  /// Page heading on the owner dashboard page
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get ownerDashboardTitle;

  /// Subtitle on the owner dashboard page
  ///
  /// In en, this message translates to:
  /// **'Manage your restaurant\'s reservations.'**
  String get ownerDashboardSubtitle;

  /// Tab label for active reservations on the owner dashboard — count is the number of active reservations
  ///
  /// In en, this message translates to:
  /// **'Active ({count})'**
  String ownerDashboardTabActive(int count);

  /// Tab label for past reservations on the owner dashboard — count is the number of past reservations
  ///
  /// In en, this message translates to:
  /// **'History ({count})'**
  String ownerDashboardTabHistory(int count);

  /// Placeholder text in the search field on the owner dashboard
  ///
  /// In en, this message translates to:
  /// **'Search by name or email...'**
  String get ownerDashboardSearchHint;

  /// Message shown when no reservations match the current search or tab on the owner dashboard
  ///
  /// In en, this message translates to:
  /// **'No reservations found.'**
  String get ownerDashboardNoReservations;

  /// Snackbar message shown after an owner marks a reservation as completed or no-show
  ///
  /// In en, this message translates to:
  /// **'Reservation resolved.'**
  String get ownerResolvedSnackbar;

  /// Column header for the customer column in the owner reservation table (desktop layout)
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get ownerTableColumnCustomer;

  /// Column header for the date column in the owner reservation table (desktop layout)
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get ownerTableColumnDate;

  /// Column header for the time column in the owner reservation table (desktop layout)
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get ownerTableColumnTime;

  /// Column header for the guest count column in the owner reservation table (desktop layout)
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get ownerTableColumnPeople;

  /// Column header for the status column in the owner reservation table (desktop layout)
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get ownerTableColumnStatus;

  /// Column header for the actions column in the owner reservation table (desktop layout)
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get ownerTableColumnActions;

  /// Tooltip and action label for the button that marks a reservation as completed (owner desktop table)
  ///
  /// In en, this message translates to:
  /// **'Mark as completed'**
  String get ownerTableMarkCompleted;

  /// Tooltip and action label for the button that marks a reservation as no-show (owner desktop table)
  ///
  /// In en, this message translates to:
  /// **'Mark as no-show'**
  String get ownerTableMarkNoShow;

  /// Badge label shown on reservations scheduled within the next few hours in the owner table
  ///
  /// In en, this message translates to:
  /// **'Arriving soon'**
  String get ownerTableArrivingSoon;

  /// Action button label to mark a reservation as completed in the mobile owner view
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get ownerMobileComplete;

  /// Action button label to mark a reservation as no-show in the mobile owner view
  ///
  /// In en, this message translates to:
  /// **'No-show'**
  String get ownerMobileNoShow;

  /// Guest count label on a reservation card in the mobile owner view — count is the number of guests
  ///
  /// In en, this message translates to:
  /// **'{count} People'**
  String ownerMobilePeopleLabel(int count);

  /// Heading on the reservation creation bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Make a Reservation'**
  String get reservationCreateTitle;

  /// Label for the date picker field on the reservation creation form
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get reservationCreateDateLabel;

  /// Label for the time picker field on the reservation creation form
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get reservationCreateTimeLabel;

  /// Label for the guest count input field on the reservation creation form
  ///
  /// In en, this message translates to:
  /// **'Number of guests'**
  String get reservationCreateGuestsLabel;

  /// Submit button on the reservation creation form
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get reservationCreateConfirmButton;

  /// Placeholder shown in the date field before a date is selected on the reservation creation form
  ///
  /// In en, this message translates to:
  /// **'Select a date'**
  String get reservationCreateSelectDate;

  /// Placeholder shown in the time field before a time is selected on the reservation creation form
  ///
  /// In en, this message translates to:
  /// **'Select a time'**
  String get reservationCreateSelectTime;

  /// Snackbar message shown after a reservation is successfully created
  ///
  /// In en, this message translates to:
  /// **'Reservation confirmed!'**
  String get reservationCreateSuccess;

  /// Heading on the reservation edit bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Edit Reservation'**
  String get reservationEditTitle;

  /// Label for the date picker field on the reservation edit form
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get reservationEditDateLabel;

  /// Label for the time picker field on the reservation edit form
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get reservationEditTimeLabel;

  /// Label for the guest count input field on the reservation edit form
  ///
  /// In en, this message translates to:
  /// **'Number of guests'**
  String get reservationEditGuestsLabel;

  /// Button to discard changes and close the reservation edit form without saving
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get reservationEditDiscardButton;

  /// Button to save changes on the reservation edit form
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get reservationEditSaveButton;

  /// Placeholder shown in the date field before a date is selected on the reservation edit form
  ///
  /// In en, this message translates to:
  /// **'Select a date'**
  String get reservationEditSelectDate;

  /// Placeholder shown in the time field before a time is selected on the reservation edit form
  ///
  /// In en, this message translates to:
  /// **'Select a time'**
  String get reservationEditSelectTime;

  /// Title of the confirmation dialog shown before canceling a reservation
  ///
  /// In en, this message translates to:
  /// **'Cancel reservation?'**
  String get reservationCancelDialogTitle;

  /// Body text of the cancellation confirmation dialog warning the user the action is irreversible
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get reservationCancelDialogContent;

  /// Button in the cancellation dialog that dismisses the dialog and keeps the reservation unchanged
  ///
  /// In en, this message translates to:
  /// **'Keep it'**
  String get reservationCancelDialogKeep;

  /// Button in the cancellation dialog that confirms and cancels the reservation
  ///
  /// In en, this message translates to:
  /// **'Cancel reservation'**
  String get reservationCancelDialogConfirm;

  /// Button on the reservation detail sheet that opens the edit form
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get reservationDetailEditButton;

  /// Button on the reservation detail sheet that opens the cancellation confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get reservationDetailCancelButton;

  /// Guest count label used when there is exactly 1 guest on the reservation detail sheet
  ///
  /// In en, this message translates to:
  /// **'1 guest'**
  String get reservationDetailGuestSingular;

  /// Guest count label used when there are 2 or more guests on the reservation detail sheet — count is the number of guests
  ///
  /// In en, this message translates to:
  /// **'{count} guests'**
  String reservationDetailGuestPlural(int count);

  /// Fallback text shown as the restaurant name on the reservation detail sheet when the restaurant name is unavailable
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get reservationDetailRestaurantFallback;

  /// Fallback text shown as the restaurant name on a reservation card when the restaurant name is unavailable
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get reservationCardRestaurantFallback;

  /// Reservation status badge label — the reservation is upcoming and active
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// Reservation status badge label — the reservation was canceled by the customer
  ///
  /// In en, this message translates to:
  /// **'Canceled'**
  String get statusCanceled;

  /// Reservation status badge label — the reservation was marked as completed by the owner
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// Reservation status badge label — the customer did not show up; marked by the owner
  ///
  /// In en, this message translates to:
  /// **'No-show'**
  String get statusNoShow;

  /// Generic retry button shown on error states throughout the app
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get errorRetry;

  /// Form validation error shown when the email field is empty
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get validatorEmailRequired;

  /// Form validation error shown when the email address format is invalid
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get validatorEmailInvalid;

  /// Form validation error shown when the password field is empty
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get validatorPasswordRequired;

  /// Form validation error shown when the password is fewer than 6 characters
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get validatorPasswordTooShort;

  /// Generic required-field validation error — fieldName is the label of the field that is empty
  ///
  /// In en, this message translates to:
  /// **'{fieldName} is required'**
  String validatorFieldRequired(String fieldName);

  /// Form validation error shown when the guest count field is empty
  ///
  /// In en, this message translates to:
  /// **'Number of guests is required'**
  String get validatorGuestsRequired;

  /// Form validation error shown when the guest count input is not a valid number
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get validatorGuestsInvalidNumber;

  /// Form validation error shown when the guest count is less than 1
  ///
  /// In en, this message translates to:
  /// **'Must be at least 1 guest'**
  String get validatorGuestsTooFew;

  /// Form validation error shown when the guest count exceeds 20
  ///
  /// In en, this message translates to:
  /// **'Cannot exceed 20 guests'**
  String get validatorGuestsTooMany;

  /// Language option label for English in the language selector
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageSelectorEnglish;

  /// Language option label for Greek in the language selector
  ///
  /// In en, this message translates to:
  /// **'Greek'**
  String get languageSelectorGreek;

  /// Error shown when login fails due to wrong email or password
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get errorAuthInvalidCredentials;

  /// Error shown when the refresh token is invalid
  ///
  /// In en, this message translates to:
  /// **'Your session is invalid. Please sign in again.'**
  String get errorAuthRefreshInvalid;

  /// Error shown when refresh token reuse is detected — all sessions are invalidated
  ///
  /// In en, this message translates to:
  /// **'Security alert: your session was used from another device. All sessions have been ended.'**
  String get errorAuthRefreshReuse;

  /// Error shown when the refresh token has expired
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get errorAuthRefreshExpired;

  /// Error shown when the user record is not found during auth
  ///
  /// In en, this message translates to:
  /// **'User not found. Please sign in again.'**
  String get errorAuthUserNotFound;

  /// Error shown when an authenticated request is made without a session
  ///
  /// In en, this message translates to:
  /// **'Please sign in to continue.'**
  String get errorAuthNotAuthenticated;

  /// Error shown when no authentication token is present
  ///
  /// In en, this message translates to:
  /// **'Authentication required.'**
  String get errorAuthNoToken;

  /// Error shown when the access token has expired
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get errorAuthTokenExpired;

  /// Error shown when the access token is malformed or invalid
  ///
  /// In en, this message translates to:
  /// **'Invalid session. Please sign in again.'**
  String get errorAuthTokenInvalid;

  /// Error shown when no refresh token cookie is present
  ///
  /// In en, this message translates to:
  /// **'No active session found. Please sign in again.'**
  String get errorAuthNoRefreshToken;

  /// Error shown when the user lacks the required role or permission
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to access this.'**
  String get errorForbidden;

  /// Error shown when an owner tries to create or manage a customer reservation
  ///
  /// In en, this message translates to:
  /// **'Only customers can make or manage reservations.'**
  String get errorReservationCustomerOnly;

  /// Error shown when a customer tries to modify another customer's reservation
  ///
  /// In en, this message translates to:
  /// **'You can only modify your own reservations.'**
  String get errorReservationNotOwner;

  /// Error shown when a customer tries to perform an owner-only action
  ///
  /// In en, this message translates to:
  /// **'Only restaurant owners can perform this action.'**
  String get errorReservationOwnerOnly;

  /// Error shown when an owner tries to resolve a reservation for another restaurant
  ///
  /// In en, this message translates to:
  /// **'This reservation belongs to a different restaurant.'**
  String get errorReservationWrongRestaurant;

  /// Error shown when the requested reservation does not exist
  ///
  /// In en, this message translates to:
  /// **'Reservation not found.'**
  String get errorReservationNotFound;

  /// Error shown when the restaurant has reached capacity for the requested time slot
  ///
  /// In en, this message translates to:
  /// **'This time slot is fully booked. Please choose another time.'**
  String get errorReservationSlotFull;

  /// Error shown when trying to modify or cancel a non-active reservation
  ///
  /// In en, this message translates to:
  /// **'Only active reservations can be modified or canceled.'**
  String get errorReservationNotActive;

  /// Error shown when the requested reservation time violates the booking window or buffer rules
  ///
  /// In en, this message translates to:
  /// **'Please choose a valid time within the booking window.'**
  String get errorReservationTimeInvalid;

  /// Error shown when an owner with no restaurant tries to view reservations
  ///
  /// In en, this message translates to:
  /// **'Your account has no restaurant assigned.'**
  String get errorReservationOwnerNoRestaurant;

  /// Button on the owner dashboard that navigates to the restaurant edit page
  ///
  /// In en, this message translates to:
  /// **'Edit Restaurant'**
  String get ownerEditRestaurantButton;

  /// Page heading on the restaurant edit page
  ///
  /// In en, this message translates to:
  /// **'Edit Restaurant'**
  String get restaurantEditTitle;

  /// Subtitle on the restaurant edit page
  ///
  /// In en, this message translates to:
  /// **'Update your restaurant details.'**
  String get restaurantEditSubtitle;

  /// Label for the name input field on the restaurant edit form
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get restaurantEditNameLabel;

  /// Label for the English description textarea on the restaurant edit form
  ///
  /// In en, this message translates to:
  /// **'Description (English)'**
  String get restaurantEditDescriptionEnLabel;

  /// Label for the Greek description textarea on the restaurant edit form
  ///
  /// In en, this message translates to:
  /// **'Description (Greek)'**
  String get restaurantEditDescriptionElLabel;

  /// Label for the address input field on the restaurant edit form
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get restaurantEditAddressLabel;

  /// Label for the phone input field on the restaurant edit form
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get restaurantEditPhoneLabel;

  /// Label for the capacity input field on the restaurant edit form
  ///
  /// In en, this message translates to:
  /// **'Capacity (tables)'**
  String get restaurantEditCapacityLabel;

  /// Submit button on the restaurant edit form
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get restaurantEditSaveButton;

  /// Snackbar message shown after the restaurant is successfully updated
  ///
  /// In en, this message translates to:
  /// **'Restaurant updated.'**
  String get restaurantEditSuccessSnackbar;

  /// Error shown when the requested restaurant does not exist
  ///
  /// In en, this message translates to:
  /// **'Restaurant not found.'**
  String get errorRestaurantNotFound;

  /// Error shown when a non-owner tries to access an owner-only restaurant endpoint
  ///
  /// In en, this message translates to:
  /// **'Only restaurant owners can perform this action.'**
  String get errorRestaurantOwnerOnly;

  /// Error shown when an owner with no restaurant tries to access GET or PUT /restaurants/me
  ///
  /// In en, this message translates to:
  /// **'Your account has no restaurant assigned.'**
  String get errorRestaurantNoneForOwner;

  /// Error shown during signup when the email is already registered
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists.'**
  String get errorUserEmailExists;

  /// Error shown when an owner signs up without selecting a restaurant
  ///
  /// In en, this message translates to:
  /// **'Please select a restaurant to manage.'**
  String get errorUserOwnerRestaurantRequired;

  /// Error shown when trying to claim a restaurant that is already owned
  ///
  /// In en, this message translates to:
  /// **'This restaurant already has an owner.'**
  String get errorRestaurantAlreadyOwned;

  /// Error shown when a unique constraint is violated (e.g. duplicate email)
  ///
  /// In en, this message translates to:
  /// **'This resource already exists.'**
  String get errorResourceConflict;

  /// Top-level error shown when the server returns a validation error envelope
  ///
  /// In en, this message translates to:
  /// **'Please check the form for errors.'**
  String get errorValidationError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['el', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'el':
      return AppLocalizationsEl();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
