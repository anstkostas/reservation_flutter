import 'package:flutter/material.dart';

/// Raw design constants — the single source of truth for all visual values.
///
/// [AppTheme] reads from here to build [ThemeData]. Widgets that need
/// a raw value outside the theme (e.g. a one-off spacing) can also import
/// this file directly.
abstract final class DesignTokens {
  // ─── Colour palette ──────────────────────────────────────────────────────

  /// Primary brand colour — slate-800 (#1E293B).
  /// Matches the React frontend's Shadcn primary.
  static const Color primary = Color(0xFF1E293B);

  /// Semantic colours used for status indicators and alerts.
  static const Color success = Color(0xFF16A34A); // green-600
  static const Color warning = Color(0xFFD97706); // amber-600
  static const Color error = Color(0xFFDC2626); // red-600
  static const Color info = Color(0xFF2563EB); // blue-600

  // ─── Typography ──────────────────────────────────────────────────────────

  /// Base font family applied to all text in the app.
  static const String fontFamily = 'Lato';

  /// Font sizes — phone (mobile-first base).
  static const PhoneFontSizes phone = PhoneFontSizes();

  /// Font sizes — tablet (600px ≤ width < 1024px).
  static const TabletFontSizes tablet = TabletFontSizes();

  /// Font sizes — desktop (width ≥ 1024px).
  static const DesktopFontSizes desktop = DesktopFontSizes();

  // ─── Border radius ───────────────────────────────────────────────────────

  static const double radiusSmall = 6;
  static const double radiusMedium = 8;
  static const double radiusLarge = 10;
  static const double radiusXl = 16;

  // ─── Spacing ─────────────────────────────────────────────────────────────

  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;
  static const double spacingXxl = 48;
}

// ─── Font size interface + tier implementations ───────────────────────────────
//
// All three classes implement [FontSizes] so that a switch over [LayoutType]
// can be typed as FontSizes — without this, Dart widens the result to Object
// and all getter access breaks.

/// Common interface for all layout-tier font size sets.
abstract class FontSizes {
  double get labelMedium;
  double get labelLarge;
  double get bodySmall;
  double get bodyMedium;
  double get bodyLarge;
  double get titleSmall;
  double get titleMedium;
  double get titleLarge;
  double get headlineSmall;
  double get headlineMedium;
}

/// Font sizes for the phone layout tier (shortestSide < 600px).
class PhoneFontSizes implements FontSizes {
  const PhoneFontSizes();

  @override
  double get labelMedium => 12;
  @override
  double get labelLarge => 14;

  @override
  double get bodySmall => 12;
  @override
  double get bodyMedium => 14;
  @override
  double get bodyLarge => 16;

  @override
  double get titleSmall => 14;
  @override
  double get titleMedium => 16;
  @override
  double get titleLarge => 18;

  @override
  double get headlineSmall => 20;
  @override
  double get headlineMedium => 24;
}

/// Font sizes for the tablet layout tier (600px ≤ shortestSide, width < 1024px).
class TabletFontSizes implements FontSizes {
  const TabletFontSizes();

  @override
  double get labelMedium => 13;
  @override
  double get labelLarge => 15;

  @override
  double get bodySmall => 13;
  @override
  double get bodyMedium => 15;
  @override
  double get bodyLarge => 17;

  @override
  double get titleSmall => 15;
  @override
  double get titleMedium => 17;
  @override
  double get titleLarge => 20;

  @override
  double get headlineSmall => 22;
  @override
  double get headlineMedium => 26;
}

/// Font sizes for the desktop layout tier (width ≥ 1024px).
class DesktopFontSizes implements FontSizes {
  const DesktopFontSizes();

  @override
  double get labelMedium => 13;
  @override
  double get labelLarge => 15;

  @override
  double get bodySmall => 13;
  @override
  double get bodyMedium => 15;
  @override
  double get bodyLarge => 17;

  @override
  double get titleSmall => 15;
  @override
  double get titleMedium => 17;
  @override
  double get titleLarge => 20;

  @override
  double get headlineSmall => 23;
  @override
  double get headlineMedium => 28;
}
