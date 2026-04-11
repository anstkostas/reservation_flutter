import 'package:flutter/material.dart';

/// Supported app locales — single source of truth for language switching.
///
/// Add entries here to support future languages. Each value carries the
/// [locale], a [flag] emoji, and a [displayName] in the target language.
enum SupportedLocale {
  english(Locale('en'), '🇬🇧', 'English'),
  greek(Locale('el'), '🇬🇷', 'Ελληνικά');

  const SupportedLocale(this.locale, this.flag, this.displayName);

  final Locale locale;
  final String flag;
  final String displayName;

  /// Returns the [SupportedLocale] matching [locale], or [english] as fallback.
  static SupportedLocale fromLocale(Locale locale) {
    return SupportedLocale.values.firstWhere(
      (entry) => entry.locale.languageCode == locale.languageCode,
      orElse: () => SupportedLocale.english,
    );
  }
}
