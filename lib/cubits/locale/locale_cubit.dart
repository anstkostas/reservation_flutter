// Localisation convention used across this app:
//
// In widget build methods, AppLocalizations is accessed as:
//   final l10n = AppLocalizations.of(context)!;
//
// "l10n" is a numeronym — shorthand for "localisation"
// (the letter 'l', 10 letters, the letter 'n').
// Same convention as "i18n" for "internationalisation".

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:antigravity_client/services/dio_client.dart';

const _kLocaleKey = 'app_locale';

/// Holds and persists the app's active [Locale].
///
/// Unlike other cubits, [LocaleCubit] is NOT registered in GetIt. It is
/// constructed directly in `main.dart` and passed into [App] via constructor
/// injection, so [loadSavedLocale] can complete before [runApp] — avoiding a
/// locale flash on startup.
///
/// [App] provides it above [MaterialApp.router] via [BlocProvider.value]. It
/// must live above [MaterialApp.router] — providing it inside the builder
/// would be too late, since [MaterialApp] locks in its locale at construction.
class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(const Locale('en'));

  /// Loads the persisted locale from SharedPreferences.
  ///
  /// Falls back to the device locale if it is 'en' or 'el'; otherwise defaults
  /// to 'en'. Call this once in [main] after [setupServiceLocator].
  Future<void> loadSavedLocale(Locale deviceLocale) async {
    final prefs = SharedPreferencesAsync();
    final saved = await prefs.getString(_kLocaleKey);
    if (saved != null) {
      GetIt.instance<DioClient>().setLanguage(saved);
      if (!isClosed) emit(Locale(saved));
      return;
    }
    // No saved preference — use device locale if supported, else English.
    final supported = ['en', 'el'];
    final resolved = supported.contains(deviceLocale.languageCode)
        ? deviceLocale
        : const Locale('en');
    GetIt.instance<DioClient>().setLanguage(resolved.languageCode);
    if (!isClosed) emit(resolved);
  }

  /// Persists [locale] to SharedPreferences and emits the new state.
  Future<void> setLocale(Locale locale) async {
    final prefs = SharedPreferencesAsync();
    await prefs.setString(_kLocaleKey, locale.languageCode);
    GetIt.instance<DioClient>().setLanguage(locale.languageCode);
    if (!isClosed) emit(locale);
  }
}
