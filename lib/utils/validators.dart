/// Validator factories for use with [FormBuilderField.validator] /
/// [TextFormField.validator].
///
/// Each factory accepts localised error strings and returns a closure with the
/// standard `String? Function(String?)` signature, compatible with
/// `flutter_form_builder` and plain `TextFormField`.
///
/// Usage:
/// ```dart
/// final l10n = AppLocalizations.of(context)!;
/// AppTextField(
///   validator: emailValidator(
///     requiredMessage: l10n.validatorEmailRequired,
///     invalidMessage:  l10n.validatorEmailInvalid,
///   ),
/// )
/// ```
library;

/// Returns a validator for email fields using the provided error strings.
String? Function(String?) emailValidator({
  required String requiredMessage,
  required String invalidMessage,
}) => (value) {
  if (value == null || value.trim().isEmpty) return requiredMessage;
  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (!emailRegex.hasMatch(value.trim())) return invalidMessage;
  return null;
};

/// Returns a validator for password fields using the provided error strings.
String? Function(String?) passwordValidator({
  required String requiredMessage,
  required String tooShortMessage,
}) => (value) {
  if (value == null || value.isEmpty) return requiredMessage;
  if (value.length < 6) return tooShortMessage;
  return null;
};

/// Returns a validator for a required text field using the provided error string.
String? Function(String?) requiredFieldValidator({
  required String requiredMessage,
}) => (value) {
  if (value == null || value.trim().isEmpty) return requiredMessage;
  return null;
};

/// Returns a validator for guest count fields using the provided error strings.
///
/// Upper bound of 20 matches the backend `.max(20)` sanity cap.
String? Function(String?) personsValidator({
  required String requiredMessage,
  required String invalidNumberMessage,
  required String tooFewMessage,
  required String tooManyMessage,
}) => (value) {
  if (value == null || value.trim().isEmpty) return requiredMessage;
  final parsed = int.tryParse(value.trim());
  if (parsed == null) return invalidNumberMessage;
  if (parsed < 1) return tooFewMessage;
  if (parsed > 20) return tooManyMessage;
  return null;
};
