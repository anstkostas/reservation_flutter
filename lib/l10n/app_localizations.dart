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

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Antigravity'**
  String get appTitle;

  /// No description provided for @navRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get navRestaurants;

  /// No description provided for @navLogIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get navLogIn;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navReservations.
  ///
  /// In en, this message translates to:
  /// **'Reservations'**
  String get navReservations;

  /// No description provided for @navLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get navLogout;

  /// No description provided for @splashHeadline.
  ///
  /// In en, this message translates to:
  /// **'Reservation App'**
  String get splashHeadline;

  /// No description provided for @splashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Book, manage, and explore your favorite restaurants seamlessly.'**
  String get splashSubtitle;

  /// No description provided for @splashCtaExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore Restaurants'**
  String get splashCtaExplore;

  /// No description provided for @splashCtaDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get splashCtaDashboard;

  /// No description provided for @splashCtaMyReservations.
  ///
  /// In en, this message translates to:
  /// **'My Reservations'**
  String get splashCtaMyReservations;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account'**
  String get loginSubtitle;

  /// No description provided for @loginEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmailLabel;

  /// No description provided for @loginEmailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get loginEmailHint;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginSubmitButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginSubmitButton;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get loginNoAccount;

  /// No description provided for @loginSignUpLink.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get loginSignUpLink;

  /// No description provided for @signupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signupTitle;

  /// No description provided for @signupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fill in the details below to get started'**
  String get signupSubtitle;

  /// No description provided for @signupFirstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get signupFirstNameLabel;

  /// No description provided for @signupLastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get signupLastNameLabel;

  /// No description provided for @signupEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get signupEmailLabel;

  /// No description provided for @signupEmailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get signupEmailHint;

  /// No description provided for @signupPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get signupPasswordLabel;

  /// No description provided for @signupRolePrompt.
  ///
  /// In en, this message translates to:
  /// **'I am signing up as a:'**
  String get signupRolePrompt;

  /// No description provided for @signupRoleCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get signupRoleCustomer;

  /// No description provided for @signupRoleOwner.
  ///
  /// In en, this message translates to:
  /// **'Restaurant owner'**
  String get signupRoleOwner;

  /// No description provided for @signupSubmitButton.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signupSubmitButton;

  /// No description provided for @signupHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get signupHaveAccount;

  /// No description provided for @signupSignInLink.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signupSignInLink;

  /// No description provided for @signupRestaurantPickerLabel.
  ///
  /// In en, this message translates to:
  /// **'Select your restaurant'**
  String get signupRestaurantPickerLabel;

  /// No description provided for @signupRestaurantPickerRequired.
  ///
  /// In en, this message translates to:
  /// **'Select a restaurant to claim'**
  String get signupRestaurantPickerRequired;

  /// No description provided for @signupNoRestaurantsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No restaurants available to claim. Sign up as a customer instead.'**
  String get signupNoRestaurantsAvailable;

  /// No description provided for @signupRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get signupRetry;

  /// No description provided for @restaurantListTitle.
  ///
  /// In en, this message translates to:
  /// **'Available Restaurants'**
  String get restaurantListTitle;

  /// No description provided for @restaurantListEmpty.
  ///
  /// In en, this message translates to:
  /// **'No restaurants available.'**
  String get restaurantListEmpty;

  /// No description provided for @restaurantCardCapacity.
  ///
  /// In en, this message translates to:
  /// **'Capacity: {capacity} Tables'**
  String restaurantCardCapacity(int capacity);

  /// No description provided for @restaurantCardViewButton.
  ///
  /// In en, this message translates to:
  /// **'View Details & Book'**
  String get restaurantCardViewButton;

  /// No description provided for @restaurantDetailAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get restaurantDetailAbout;

  /// No description provided for @restaurantDetailCapacityChip.
  ///
  /// In en, this message translates to:
  /// **'Capacity: {capacity} Tables'**
  String restaurantDetailCapacityChip(int capacity);

  /// No description provided for @restaurantDetailMakeReservationTitle.
  ///
  /// In en, this message translates to:
  /// **'Make a Reservation'**
  String get restaurantDetailMakeReservationTitle;

  /// No description provided for @restaurantDetailMakeReservationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Secure your table for an unforgettable dining experience.'**
  String get restaurantDetailMakeReservationSubtitle;

  /// No description provided for @restaurantDetailBookButton.
  ///
  /// In en, this message translates to:
  /// **'Book a Table'**
  String get restaurantDetailBookButton;

  /// No description provided for @reservationHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'My Reservations'**
  String get reservationHistoryTitle;

  /// No description provided for @reservationHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'View and manage your dining bookings.'**
  String get reservationHistorySubtitle;

  /// No description provided for @reservationHistoryBookButton.
  ///
  /// In en, this message translates to:
  /// **'Book a Table'**
  String get reservationHistoryBookButton;

  /// No description provided for @reservationHistoryTabUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming ({count})'**
  String reservationHistoryTabUpcoming(int count);

  /// No description provided for @reservationHistoryTabHistory.
  ///
  /// In en, this message translates to:
  /// **'History ({count})'**
  String reservationHistoryTabHistory(int count);

  /// No description provided for @reservationHistoryEmptyUpcomingTitle.
  ///
  /// In en, this message translates to:
  /// **'No upcoming reservations'**
  String get reservationHistoryEmptyUpcomingTitle;

  /// No description provided for @reservationHistoryEmptyUpcomingDetail.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any active bookings at the moment. Explore restaurants and book your next meal!'**
  String get reservationHistoryEmptyUpcomingDetail;

  /// No description provided for @reservationHistoryEmptyPastTitle.
  ///
  /// In en, this message translates to:
  /// **'No past reservations'**
  String get reservationHistoryEmptyPastTitle;

  /// No description provided for @reservationHistoryEmptyPastDetail.
  ///
  /// In en, this message translates to:
  /// **'No reservation history yet.'**
  String get reservationHistoryEmptyPastDetail;

  /// No description provided for @reservationUpdatedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Reservation updated.'**
  String get reservationUpdatedSnackbar;

  /// No description provided for @ownerDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get ownerDashboardTitle;

  /// No description provided for @ownerDashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your restaurant\'s reservations.'**
  String get ownerDashboardSubtitle;

  /// No description provided for @ownerDashboardTabActive.
  ///
  /// In en, this message translates to:
  /// **'Active ({count})'**
  String ownerDashboardTabActive(int count);

  /// No description provided for @ownerDashboardTabHistory.
  ///
  /// In en, this message translates to:
  /// **'History ({count})'**
  String ownerDashboardTabHistory(int count);

  /// No description provided for @ownerDashboardSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or email...'**
  String get ownerDashboardSearchHint;

  /// No description provided for @ownerDashboardNoReservations.
  ///
  /// In en, this message translates to:
  /// **'No reservations found.'**
  String get ownerDashboardNoReservations;

  /// No description provided for @ownerResolvedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Reservation resolved.'**
  String get ownerResolvedSnackbar;

  /// No description provided for @ownerTableColumnCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get ownerTableColumnCustomer;

  /// No description provided for @ownerTableColumnDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get ownerTableColumnDate;

  /// No description provided for @ownerTableColumnTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get ownerTableColumnTime;

  /// No description provided for @ownerTableColumnPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get ownerTableColumnPeople;

  /// No description provided for @ownerTableColumnStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get ownerTableColumnStatus;

  /// No description provided for @ownerTableColumnActions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get ownerTableColumnActions;

  /// No description provided for @ownerTableMarkCompleted.
  ///
  /// In en, this message translates to:
  /// **'Mark as completed'**
  String get ownerTableMarkCompleted;

  /// No description provided for @ownerTableMarkNoShow.
  ///
  /// In en, this message translates to:
  /// **'Mark as no-show'**
  String get ownerTableMarkNoShow;

  /// No description provided for @ownerTableArrivingSoon.
  ///
  /// In en, this message translates to:
  /// **'Arriving soon'**
  String get ownerTableArrivingSoon;

  /// No description provided for @ownerMobileComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get ownerMobileComplete;

  /// No description provided for @ownerMobileNoShow.
  ///
  /// In en, this message translates to:
  /// **'No-show'**
  String get ownerMobileNoShow;

  /// No description provided for @ownerMobilePeopleLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} People'**
  String ownerMobilePeopleLabel(int count);

  /// No description provided for @reservationCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Make a Reservation'**
  String get reservationCreateTitle;

  /// No description provided for @reservationCreateDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get reservationCreateDateLabel;

  /// No description provided for @reservationCreateTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get reservationCreateTimeLabel;

  /// No description provided for @reservationCreateGuestsLabel.
  ///
  /// In en, this message translates to:
  /// **'Number of guests'**
  String get reservationCreateGuestsLabel;

  /// No description provided for @reservationCreateConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get reservationCreateConfirmButton;

  /// No description provided for @reservationCreateSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Select a date'**
  String get reservationCreateSelectDate;

  /// No description provided for @reservationCreateSelectTime.
  ///
  /// In en, this message translates to:
  /// **'Select a time'**
  String get reservationCreateSelectTime;

  /// No description provided for @reservationCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Reservation confirmed!'**
  String get reservationCreateSuccess;

  /// No description provided for @reservationEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Reservation'**
  String get reservationEditTitle;

  /// No description provided for @reservationEditDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get reservationEditDateLabel;

  /// No description provided for @reservationEditTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get reservationEditTimeLabel;

  /// No description provided for @reservationEditGuestsLabel.
  ///
  /// In en, this message translates to:
  /// **'Number of guests'**
  String get reservationEditGuestsLabel;

  /// No description provided for @reservationEditDiscardButton.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get reservationEditDiscardButton;

  /// No description provided for @reservationEditSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get reservationEditSaveButton;

  /// No description provided for @reservationEditSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Select a date'**
  String get reservationEditSelectDate;

  /// No description provided for @reservationEditSelectTime.
  ///
  /// In en, this message translates to:
  /// **'Select a time'**
  String get reservationEditSelectTime;

  /// No description provided for @reservationCancelDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel reservation?'**
  String get reservationCancelDialogTitle;

  /// No description provided for @reservationCancelDialogContent.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get reservationCancelDialogContent;

  /// No description provided for @reservationCancelDialogKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep it'**
  String get reservationCancelDialogKeep;

  /// No description provided for @reservationCancelDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Cancel reservation'**
  String get reservationCancelDialogConfirm;

  /// No description provided for @reservationDetailEditButton.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get reservationDetailEditButton;

  /// No description provided for @reservationDetailCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get reservationDetailCancelButton;

  /// No description provided for @reservationDetailGuestSingular.
  ///
  /// In en, this message translates to:
  /// **'1 guest'**
  String get reservationDetailGuestSingular;

  /// No description provided for @reservationDetailGuestPlural.
  ///
  /// In en, this message translates to:
  /// **'{count} guests'**
  String reservationDetailGuestPlural(int count);

  /// No description provided for @reservationDetailRestaurantFallback.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get reservationDetailRestaurantFallback;

  /// No description provided for @reservationCardRestaurantFallback.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get reservationCardRestaurantFallback;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// No description provided for @statusCanceled.
  ///
  /// In en, this message translates to:
  /// **'Canceled'**
  String get statusCanceled;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusNoShow.
  ///
  /// In en, this message translates to:
  /// **'No-show'**
  String get statusNoShow;

  /// No description provided for @errorRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get errorRetry;

  /// No description provided for @validatorEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get validatorEmailRequired;

  /// No description provided for @validatorEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get validatorEmailInvalid;

  /// No description provided for @validatorPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get validatorPasswordRequired;

  /// No description provided for @validatorPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get validatorPasswordTooShort;

  /// No description provided for @validatorFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'{fieldName} is required'**
  String validatorFieldRequired(String fieldName);

  /// No description provided for @validatorGuestsRequired.
  ///
  /// In en, this message translates to:
  /// **'Number of guests is required'**
  String get validatorGuestsRequired;

  /// No description provided for @validatorGuestsInvalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get validatorGuestsInvalidNumber;

  /// No description provided for @validatorGuestsTooFew.
  ///
  /// In en, this message translates to:
  /// **'Must be at least 1 guest'**
  String get validatorGuestsTooFew;

  /// No description provided for @validatorGuestsTooMany.
  ///
  /// In en, this message translates to:
  /// **'Cannot exceed 20 guests'**
  String get validatorGuestsTooMany;

  /// No description provided for @languageSelectorEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageSelectorEnglish;

  /// No description provided for @languageSelectorGreek.
  ///
  /// In en, this message translates to:
  /// **'Greek'**
  String get languageSelectorGreek;
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
