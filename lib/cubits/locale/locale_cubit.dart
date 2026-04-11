import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleKey = 'app_locale';

/// Holds and persists the app's active [Locale].
///
/// [LocaleCubit] is a lazy singleton in GetIt and provided above [MaterialApp]
/// so locale state is available before the widget tree is built. It must live
/// above [MaterialApp.router] — providing it inside the builder would be too late.
class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(const Locale('en'));

  /// Loads the persisted locale from SharedPreferences.
  ///
  /// Falls back to the device locale if it is 'en' or 'el'; otherwise defaults
  /// to 'en'. Call this once in [main] after [setupServiceLocator].
  Future<void> loadSavedLocale(Locale deviceLocale) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kLocaleKey);
    if (saved != null) {
      if (!isClosed) emit(Locale(saved));
      return;
    }
    // No saved preference — use device locale if supported, else English.
    final supported = ['en', 'el'];
    final resolved = supported.contains(deviceLocale.languageCode)
        ? deviceLocale
        : const Locale('en');
    if (!isClosed) emit(resolved);
  }

  /// Persists [locale] to SharedPreferences and emits the new state.
  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocaleKey, locale.languageCode);
    if (!isClosed) emit(locale);
  }
}
