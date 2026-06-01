import 'package:flutter/widgets.dart';

/// Responsive layout breakpoints — aligned to Tailwind CSS defaults.
///
/// All layout decisions use [Size.width] exclusively. Use the numeric
/// constants ([md], [lg], etc.) for inline comparisons, or the named
/// helpers ([isDesktop], [isXl], [is2xl]) for common checks.
///
/// ## Fine-grained helpers
/// [isXl] and [is2xl] mirror Tailwind's xl/2xl for specific widgets
/// (e.g. the 4-column restaurant grid at 2xl). Use these sparingly.
///
/// Usage:
/// ```dart
/// final size = MediaQuery.sizeOf(context);
/// if (size.width < Breakpoints.md) { /* phone layout */ }
/// ```
abstract final class Breakpoints {
  // ─── Tailwind breakpoint constants (width-based) ──────────────────────────
  static const double sm = 640;
  static const double md = 768;
  static const double lg = 1024;
  static const double xl = 1280;
  static const double xxl = 1536; // Tailwind's 2xl

  // ─── Width-only helpers ───────────────────────────────────────────────────

  static bool isDesktop(Size size) => size.width >= lg;

  /// True when width ≥ 1280px (Tailwind xl). Use for subtle layout tweaks
  /// within the desktop tier — not as a fourth layout tier.
  static bool isXl(Size size) => size.width >= xl;

  /// True when width ≥ 1536px (Tailwind 2xl). Used for the 4-column
  /// restaurant grid; available for future fine-grained use.
  static bool is2xl(Size size) => size.width >= xxl;
}
