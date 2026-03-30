/// Form validator functions for use with [TextFormField.validator].
///
/// Each function returns null on valid input, or an error string to display.
/// Pass these directly to the `validator` parameter — no wrapper needed.
library;

/// Validates that [value] is a non-empty, well-formed email address.
String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Email is required';
  }
  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (!emailRegex.hasMatch(value.trim())) {
    return 'Enter a valid email address';
  }
  return null;
}

/// Validates that [value] meets minimum password requirements.
String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password is required';
  }
  if (value.length < 6) {
    return 'Password must be at least 6 characters';
  }
  return null;
}

/// Validates that [value] is non-empty.
///
/// [fieldName] is shown in the error message, e.g. "First name is required".
String? validateRequired(String? value, String fieldName) {
  if (value == null || value.trim().isEmpty) {
    return '$fieldName is required';
  }
  return null;
}

/// Validates that [value] is a valid number of persons (1–20).
///
/// Upper bound of 20 matches the backend `.max(20)` sanity cap.
String? validatePersons(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Number of guests is required';
  }
  final parsed = int.tryParse(value.trim());
  if (parsed == null) {
    return 'Enter a valid number';
  }
  if (parsed < 1) {
    return 'Must be at least 1 guest';
  }
  if (parsed > 20) {
    return 'Cannot exceed 20 guests';
  }
  return null;
}
