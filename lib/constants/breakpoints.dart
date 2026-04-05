import 'package:flutter/widgets.dart';

/// The three layout tiers used across the app.
enum LayoutType { phone, tablet, desktop }

/// Responsive layout breakpoints — aligned to Tailwind CSS defaults.
///
/// ## Layout tiers
/// Widgets call [Breakpoints.layoutOf] with [MediaQuery.sizeOf(context)] to
/// get the current layout tier — no prop drilling, no LayoutBuilder needed.
///
/// [Size.shortestSide] is used for phone detection so that a phone in
/// landscape mode doesn't incorrectly snap to a tablet layout.
///
/// Tier boundaries match Tailwind's [md] and [lg] breakpoints:
/// - phone  → shortestSide < 768
/// - tablet → 768 ≤ shortestSide, width < 1024
/// - desktop → width ≥ 1024
///
/// ## Fine-grained helpers
/// [isXl] and [is2xl] mirror Tailwind's xl/2xl for specific widgets
/// (e.g. the 4-column restaurant grid at 2xl). Use these sparingly — the
/// three-tier layout system covers the vast majority of cases.
///
/// Usage:
/// ```dart
/// final layout = Breakpoints.layoutOf(MediaQuery.sizeOf(context));
/// ```
abstract final class Breakpoints {
  // ─── Tailwind breakpoint constants (width-based) ──────────────────────────
  static const double sm  =  640;
  static const double md  =  768;
  static const double lg  = 1024;
  static const double xl  = 1280;
  static const double xxl = 1536; // Tailwind's 2xl

  // ─── Main layout tier ─────────────────────────────────────────────────────

  /// Returns the [LayoutType] for the given [size].
  ///
  /// Uses [Size.shortestSide] for phone detection — orientation-safe.
  static LayoutType layoutOf(Size size) {
    if (size.shortestSide < md) return LayoutType.phone;
    if (size.width < lg) return LayoutType.tablet;
    return LayoutType.desktop;
  }

  static bool isPhone(Size size)   => size.shortestSide < md;
  static bool isTablet(Size size)  => size.shortestSide >= md && size.width < lg;
  static bool isDesktop(Size size) => size.width >= lg;

  // ─── Fine-grained width helpers ───────────────────────────────────────────

  /// True when width ≥ 1280px (Tailwind xl). Use for subtle layout tweaks
  /// within the desktop tier — not as a fourth layout tier.
  static bool isXl(Size size)  => size.width >= xl;

  /// True when width ≥ 1536px (Tailwind 2xl). Used for the 4-column
  /// restaurant grid; available for future fine-grained use.
  static bool is2xl(Size size) => size.width >= xxl;
}

/// Builds a different widget tree based on the current [LayoutType].
///
/// Calls [MediaQuery.sizeOf] internally — no LayoutBuilder or prop drilling
/// needed at the call site.
///
/// [tablet] is optional and falls back to [desktop] when not provided,
/// since tablet users generally benefit from the wider desktop layout.
///
/// Usage:
/// ```dart
/// ResponsiveLayout(
///   phone: LoginMobile(),
///   desktop: LoginDesktop(),
/// )
/// ```
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.phone,
    this.tablet,
    required this.desktop,
  });

  final Widget phone;

  /// Falls back to [desktop] if not provided.
  final Widget? tablet;

  final Widget desktop;

  @override
  Widget build(BuildContext context) {
    final layout = Breakpoints.layoutOf(MediaQuery.sizeOf(context));
    return switch (layout) {
      LayoutType.phone => phone,
      LayoutType.tablet => tablet ?? desktop,
      LayoutType.desktop => desktop,
    };
  }
}
