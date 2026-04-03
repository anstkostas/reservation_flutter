import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/breakpoints.dart';
import 'design_tokens.dart';

/// App-wide theme configuration.
///
/// Call [themeData] from [MaterialApp.router]'s [builder] property, passing
/// [MediaQuery.sizeOf(context)]. This lets the entire widget tree get
/// responsive font sizes via [Theme.of(context)] — no [LayoutBuilder] needed
/// in individual widgets.
///
/// ```dart
/// MaterialApp.router(
///   builder: (context, child) {
///     final size = MediaQuery.sizeOf(context);
///     return Theme(
///       data: AppTheme.themeData(size),
///       child: child!,
///     );
///   },
/// )
/// ```
abstract final class AppTheme {
  /// Builds [ThemeData] with font sizes appropriate for the given screen [size].
  ///
  /// Uses [Breakpoints.layoutOf] to determine the layout tier, then picks
  /// the matching font size set from [DesignTokens].
  static ThemeData themeData(Size size) {
    final layout = Breakpoints.layoutOf(size);

    final FontSizes sizes = switch (layout) {
      LayoutType.phone => DesignTokens.phone,
      LayoutType.tablet => DesignTokens.tablet,
      LayoutType.desktop => DesignTokens.desktop,
    };

    final colorScheme = ColorScheme.fromSeed(
      seedColor: DesignTokens.primary,
      brightness: Brightness.light,
    );

    // Build text theme from Google Fonts base, then override each role's
    // font size with the tier-appropriate value from DesignTokens.
    final textTheme = GoogleFonts.latoTextTheme().copyWith(
      labelMedium: GoogleFonts.lato(fontSize: sizes.labelMedium),
      labelLarge: GoogleFonts.lato(
        fontSize: sizes.labelLarge,
        fontWeight: FontWeight.w600,
      ),
      bodySmall: GoogleFonts.lato(fontSize: sizes.bodySmall),
      bodyMedium: GoogleFonts.lato(fontSize: sizes.bodyMedium),
      bodyLarge: GoogleFonts.lato(fontSize: sizes.bodyLarge),
      titleSmall: GoogleFonts.lato(
        fontSize: sizes.titleSmall,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: GoogleFonts.lato(
        fontSize: sizes.titleMedium,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: GoogleFonts.lato(
        fontSize: sizes.titleLarge,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: GoogleFonts.lato(
        fontSize: sizes.headlineSmall,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: GoogleFonts.lato(
        fontSize: sizes.headlineMedium,
        fontWeight: FontWeight.w700,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,

      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.lato(
          fontSize: sizes.titleLarge,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 2,
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacingLg,
            vertical: DesignTokens.spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          ),
          textStyle: GoogleFonts.lato(
            fontSize: sizes.labelLarge,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacingLg,
            vertical: DesignTokens.spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          ),
          textStyle: GoogleFonts.lato(
            fontSize: sizes.labelLarge,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacingMd,
          vertical: DesignTokens.spacingMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          borderSide: BorderSide(color: colorScheme.error),
        ),
      ),
    );
  }
}
