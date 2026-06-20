// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Modern Greek (`el`).
class AppLocalizationsEl extends AppLocalizations {
  AppLocalizationsEl([String locale = 'el']) : super(locale);

  @override
  String get appTitle => 'Antigravity';

  @override
  String get navRestaurants => 'Εστιατόρια';

  @override
  String get navLogIn => 'Σύνδεση';

  @override
  String get navDashboard => 'Πίνακας ελέγχου';

  @override
  String get navMyRestaurant => 'Το εστιατόριό μου';

  @override
  String get navReservations => 'Κρατήσεις';

  @override
  String get navLogout => 'Αποσύνδεση';

  @override
  String get splashHeadline => 'Εφαρμογή Κρατήσεων';

  @override
  String get splashSubtitle =>
      'Κάντε κράτηση, διαχειριστείτε και εξερευνήστε τα αγαπημένα σας εστιατόρια.';

  @override
  String get splashCtaExplore => 'Εξερεύνηση Εστιατορίων';

  @override
  String get splashCtaDashboard => 'Πίνακας ελέγχου';

  @override
  String get splashCtaMyReservations => 'Οι Κρατήσεις μου';

  @override
  String get loginTitle => 'Καλωσορίσατε';

  @override
  String get loginSubtitle => 'Συνδεθείτε στον λογαριασμό σας';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginEmailHint => 'you@example.com';

  @override
  String get loginPasswordLabel => 'Κωδικός πρόσβασης';

  @override
  String get loginSubmitButton => 'Σύνδεση';

  @override
  String get loginNoAccount => 'Δεν έχετε λογαριασμό;';

  @override
  String get loginSignUpLink => 'Εγγραφή';

  @override
  String get signupTitle => 'Δημιουργία λογαριασμού';

  @override
  String get signupSubtitle =>
      'Συμπληρώστε τα στοιχεία παρακάτω για να ξεκινήσετε';

  @override
  String get signupFirstNameLabel => 'Όνομα';

  @override
  String get signupLastNameLabel => 'Επώνυμο';

  @override
  String get signupEmailLabel => 'Email';

  @override
  String get signupEmailHint => 'you@example.com';

  @override
  String get signupPasswordLabel => 'Κωδικός πρόσβασης';

  @override
  String get signupRolePrompt => 'Εγγράφομαι ως:';

  @override
  String get signupRoleCustomer => 'Πελάτης';

  @override
  String get signupRoleOwner => 'Ιδιοκτήτης εστιατορίου';

  @override
  String get signupSubmitButton => 'Δημιουργία λογαριασμού';

  @override
  String get signupHaveAccount => 'Έχετε ήδη λογαριασμό;';

  @override
  String get signupSignInLink => 'Σύνδεση';

  @override
  String get signupRestaurantPickerLabel => 'Επιλέξτε το εστιατόριό σας';

  @override
  String get signupRestaurantPickerRequired =>
      'Επιλέξτε ένα εστιατόριο για αξίωση';

  @override
  String get signupNoRestaurantsAvailable =>
      'Δεν υπάρχουν διαθέσιμα εστιατόρια. Εγγραφείτε ως πελάτης.';

  @override
  String get signupRetry => 'Επανάληψη';

  @override
  String get restaurantListTitle => 'Διαθέσιμα Εστιατόρια';

  @override
  String get restaurantListEmpty => 'Δεν υπάρχουν διαθέσιμα εστιατόρια.';

  @override
  String restaurantCardCapacity(int capacity) {
    return 'Χωρητικότητα: $capacity Τραπέζια';
  }

  @override
  String get restaurantCardViewButton => 'Λεπτομέρειες & Κράτηση';

  @override
  String get restaurantDetailAbout => 'Σχετικά';

  @override
  String get restaurantDetailAddress => 'Διεύθυνση';

  @override
  String get restaurantDetailPhone => 'Τηλέφωνο';

  @override
  String restaurantDetailCapacityChip(int capacity) {
    return 'Χωρητικότητα: $capacity Τραπέζια';
  }

  @override
  String get restaurantDetailMakeReservationTitle => 'Κάντε Κράτηση';

  @override
  String get restaurantDetailMakeReservationSubtitle =>
      'Εξασφαλίστε το τραπέζι σας για μια αξέχαστη γαστρονομική εμπειρία.';

  @override
  String get restaurantDetailBookButton => 'Κράτηση Τραπεζιού';

  @override
  String get reservationHistoryTitle => 'Οι Κρατήσεις μου';

  @override
  String get reservationHistorySubtitle =>
      'Δείτε και διαχειριστείτε τις κρατήσεις σας.';

  @override
  String get reservationHistoryBookButton => 'Κράτηση Τραπεζιού';

  @override
  String reservationHistoryTabUpcoming(int count) {
    return 'Επερχόμενες ($count)';
  }

  @override
  String reservationHistoryTabHistory(int count) {
    return 'Ιστορικό ($count)';
  }

  @override
  String get reservationHistoryEmptyUpcomingTitle =>
      'Δεν υπάρχουν επερχόμενες κρατήσεις';

  @override
  String get reservationHistoryEmptyUpcomingDetail =>
      'Δεν έχετε ενεργές κρατήσεις αυτή τη στιγμή. Εξερευνήστε εστιατόρια και κλείστε το επόμενο τραπέζι σας!';

  @override
  String get reservationHistoryEmptyPastTitle =>
      'Δεν υπάρχουν παλαιότερες κρατήσεις';

  @override
  String get reservationHistoryEmptyPastDetail =>
      'Δεν υπάρχει ακόμα ιστορικό κρατήσεων.';

  @override
  String get reservationUpdatedSnackbar => 'Η κράτηση ενημερώθηκε.';

  @override
  String get ownerDashboardTitle => 'Πίνακας ελέγχου';

  @override
  String get ownerDashboardSubtitle =>
      'Διαχειριστείτε τις κρατήσεις του εστιατορίου σας.';

  @override
  String ownerDashboardTabActive(int count) {
    return 'Ενεργές ($count)';
  }

  @override
  String ownerDashboardTabHistory(int count) {
    return 'Ιστορικό ($count)';
  }

  @override
  String get ownerDashboardSearchHint => 'Αναζήτηση με όνομα ή email...';

  @override
  String get ownerDashboardNoReservations => 'Δεν βρέθηκαν κρατήσεις.';

  @override
  String get ownerResolvedSnackbar => 'Η κράτηση ολοκληρώθηκε.';

  @override
  String get ownerTableColumnCustomer => 'Πελάτης';

  @override
  String get ownerTableColumnDate => 'Ημερομηνία';

  @override
  String get ownerTableColumnTime => 'Ώρα';

  @override
  String get ownerTableColumnPeople => 'Άτομα';

  @override
  String get ownerTableColumnStatus => 'Κατάσταση';

  @override
  String get ownerTableColumnActions => 'Ενέργειες';

  @override
  String get ownerTableMarkCompleted => 'Σημείωση ως ολοκληρωμένη';

  @override
  String get ownerTableMarkNoShow => 'Σημείωση ως no-show';

  @override
  String get ownerTableArrivingSoon => 'Φτάνει σύντομα';

  @override
  String get ownerMobileComplete => 'Ολοκλήρωση';

  @override
  String get ownerMobileNoShow => 'No-show';

  @override
  String ownerMobilePeopleLabel(int count) {
    return '$count Άτομα';
  }

  @override
  String get reservationCreateTitle => 'Κάντε Κράτηση';

  @override
  String get reservationCreateDateLabel => 'Ημερομηνία';

  @override
  String get reservationCreateTimeLabel => 'Ώρα';

  @override
  String get reservationCreateGuestsLabel => 'Αριθμός καλεσμένων';

  @override
  String get reservationCreateConfirmButton => 'Επιβεβαίωση';

  @override
  String get reservationCreateSelectDate => 'Επιλέξτε ημερομηνία';

  @override
  String get reservationCreateSelectTime => 'Επιλέξτε ώρα';

  @override
  String get reservationCreateSuccess => 'Η κράτηση επιβεβαιώθηκε!';

  @override
  String get reservationEditTitle => 'Επεξεργασία Κράτησης';

  @override
  String get reservationEditDateLabel => 'Ημερομηνία';

  @override
  String get reservationEditTimeLabel => 'Ώρα';

  @override
  String get reservationEditGuestsLabel => 'Αριθμός καλεσμένων';

  @override
  String get reservationEditDiscardButton => 'Απόρριψη';

  @override
  String get reservationEditSaveButton => 'Αποθήκευση αλλαγών';

  @override
  String get reservationEditSelectDate => 'Επιλέξτε ημερομηνία';

  @override
  String get reservationEditSelectTime => 'Επιλέξτε ώρα';

  @override
  String get reservationCancelDialogTitle => 'Ακύρωση κράτησης;';

  @override
  String get reservationCancelDialogContent =>
      'Η ενέργεια αυτή δεν μπορεί να αναιρεθεί.';

  @override
  String get reservationCancelDialogKeep => 'Διατήρηση';

  @override
  String get reservationCancelDialogConfirm => 'Ακύρωση κράτησης';

  @override
  String get reservationDetailEditButton => 'Επεξεργασία';

  @override
  String get reservationDetailCancelButton => 'Ακύρωση';

  @override
  String get reservationDetailGuestSingular => '1 άτομο';

  @override
  String reservationDetailGuestPlural(int count) {
    return '$count άτομα';
  }

  @override
  String get reservationDetailRestaurantFallback => 'Εστιατόριο';

  @override
  String get reservationCardRestaurantFallback => 'Εστιατόριο';

  @override
  String get statusActive => 'Ενεργή';

  @override
  String get statusCanceled => 'Ακυρωμένη';

  @override
  String get statusCompleted => 'Ολοκληρωμένη';

  @override
  String get statusNoShow => 'No-show';

  @override
  String get errorRetry => 'Επανάληψη';

  @override
  String get validatorEmailRequired => 'Απαιτείται email';

  @override
  String get validatorEmailInvalid => 'Εισάγετε έγκυρη διεύθυνση email';

  @override
  String get validatorPasswordRequired => 'Απαιτείται κωδικός';

  @override
  String get validatorPasswordTooShort =>
      'Ο κωδικός πρέπει να έχει τουλάχιστον 6 χαρακτήρες';

  @override
  String validatorFieldRequired(String fieldName) {
    return 'Το πεδίο $fieldName είναι υποχρεωτικό';
  }

  @override
  String get validatorGuestsRequired => 'Απαιτείται αριθμός καλεσμένων';

  @override
  String get validatorGuestsInvalidNumber => 'Εισάγετε έγκυρο αριθμό';

  @override
  String get validatorGuestsTooFew => 'Πρέπει να είναι τουλάχιστον 1 άτομο';

  @override
  String get validatorGuestsTooMany => 'Δεν μπορεί να υπερβαίνει τα 20 άτομα';

  @override
  String get languageSelectorEnglish => 'Αγγλικά';

  @override
  String get languageSelectorGreek => 'Ελληνικά';

  @override
  String get errorAuthInvalidCredentials => 'Λάθος email ή κωδικός πρόσβασης';

  @override
  String get errorAuthRefreshInvalid =>
      'Η συνεδρία σας είναι άκυρη. Παρακαλώ συνδεθείτε ξανά.';

  @override
  String get errorAuthRefreshReuse =>
      'Ειδοποίηση ασφαλείας: η συνεδρία χρησιμοποιήθηκε από άλλη συσκευή. Όλες οι συνεδρίες τερματίστηκαν.';

  @override
  String get errorAuthRefreshExpired =>
      'Η συνεδρία σας έχει λήξει. Παρακαλώ συνδεθείτε ξανά.';

  @override
  String get errorAuthUserNotFound =>
      'Ο χρήστης δεν βρέθηκε. Παρακαλώ συνδεθείτε ξανά.';

  @override
  String get errorAuthNotAuthenticated =>
      'Παρακαλώ συνδεθείτε για να συνεχίσετε.';

  @override
  String get errorAuthNoToken => 'Απαιτείται ταυτοποίηση.';

  @override
  String get errorAuthTokenExpired =>
      'Η συνεδρία σας έχει λήξει. Παρακαλώ συνδεθείτε ξανά.';

  @override
  String get errorAuthTokenInvalid =>
      'Μη έγκυρη συνεδρία. Παρακαλώ συνδεθείτε ξανά.';

  @override
  String get errorAuthNoRefreshToken =>
      'Δεν βρέθηκε ενεργή συνεδρία. Παρακαλώ συνδεθείτε ξανά.';

  @override
  String get errorForbidden => 'Δεν έχετε δικαίωμα πρόσβασης.';

  @override
  String get errorReservationCustomerOnly =>
      'Μόνο οι πελάτες μπορούν να κάνουν ή να διαχειριστούν κρατήσεις.';

  @override
  String get errorReservationNotOwner =>
      'Μπορείτε να τροποποιήσετε μόνο τις δικές σας κρατήσεις.';

  @override
  String get errorReservationOwnerOnly =>
      'Μόνο οι ιδιοκτήτες εστιατορίων μπορούν να εκτελέσουν αυτή την ενέργεια.';

  @override
  String get errorReservationWrongRestaurant =>
      'Αυτή η κράτηση ανήκει σε άλλο εστιατόριο.';

  @override
  String get errorReservationNotFound => 'Η κράτηση δεν βρέθηκε.';

  @override
  String get errorReservationSlotFull =>
      'Αυτή η χρονική θέση είναι πλήρως κλεισμένη. Παρακαλώ επιλέξτε άλλη ώρα.';

  @override
  String get errorReservationNotActive =>
      'Μόνο ενεργές κρατήσεις μπορούν να τροποποιηθούν ή να ακυρωθούν.';

  @override
  String get errorReservationTimeInvalid =>
      'Παρακαλώ επιλέξτε έγκυρη ώρα εντός του παραθύρου κρατήσεων.';

  @override
  String get errorReservationOwnerNoRestaurant =>
      'Ο λογαριασμός σας δεν έχει ανατεθεί εστιατόριο.';

  @override
  String get ownerEditRestaurantButton => 'Επεξεργασία Εστιατορίου';

  @override
  String get restaurantEditTitle => 'Επεξεργασία Εστιατορίου';

  @override
  String get restaurantEditSubtitle =>
      'Ενημερώστε τα στοιχεία του εστιατορίου σας.';

  @override
  String get restaurantEditNameLabel => 'Όνομα';

  @override
  String get restaurantEditDescriptionEnLabel => 'Περιγραφή (Αγγλικά)';

  @override
  String get restaurantEditDescriptionElLabel => 'Περιγραφή (Ελληνικά)';

  @override
  String get restaurantEditAddressLabel => 'Διεύθυνση';

  @override
  String get restaurantEditPhoneLabel => 'Τηλέφωνο';

  @override
  String get restaurantEditCapacityLabel => 'Χωρητικότητα (τραπέζια)';

  @override
  String get restaurantEditSaveButton => 'Αποθήκευση αλλαγών';

  @override
  String get restaurantEditSuccessSnackbar => 'Το εστιατόριο ενημερώθηκε.';

  @override
  String get errorRestaurantNotFound => 'Το εστιατόριο δεν βρέθηκε.';

  @override
  String get errorRestaurantOwnerOnly =>
      'Μόνο ιδιοκτήτες εστιατορίων μπορούν να εκτελέσουν αυτή την ενέργεια.';

  @override
  String get errorRestaurantNoneForOwner =>
      'Ο λογαριασμός σας δεν έχει εκχωρηθεί εστιατόριο.';

  @override
  String get errorUserEmailExists =>
      'Υπάρχει ήδη λογαριασμός με αυτό το email.';

  @override
  String get errorUserOwnerRestaurantRequired =>
      'Παρακαλώ επιλέξτε εστιατόριο για διαχείριση.';

  @override
  String get errorRestaurantAlreadyOwned =>
      'Αυτό το εστιατόριο έχει ήδη ιδιοκτήτη.';

  @override
  String get errorResourceConflict => 'Αυτός ο πόρος υπάρχει ήδη.';

  @override
  String get errorValidationError => 'Παρακαλώ ελέγξτε τη φόρμα για σφάλματα.';
}
