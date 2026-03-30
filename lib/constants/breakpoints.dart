import 'package:flutter/widgets.dart';

/// The three layout tiers used across the app.
enum LayoutType { phone, tablet, desktop }

/// Responsive layout breakpoints.
///
/// Widgets call [Breakpoints.layoutOf] with [MediaQuery.sizeOf(context)] to
/// get the current layout tier — no prop drilling, no LayoutBuilder needed.
///
/// [Size.shortestSide] is used for phone detection so that a phone in
/// landscape mode doesn't incorrectly snap to a tablet layout.
///
/// Usage:
/// ```dart
/// final layout = Breakpoints.layoutOf(MediaQuery.sizeOf(context));
/// ```
abstract final class Breakpoints {
  /// Shortest side below this → phone layout.
  static const double tablet = 600;

  /// Width above this → desktop layout.
  static const double desktop = 1024;

  /// Returns the [LayoutType] for the given [size].
  ///
  /// Uses [Size.shortestSide] for phone detection — orientation-safe.
  static LayoutType layoutOf(Size size) {
    if (size.shortestSide < tablet) return LayoutType.phone;
    if (size.width < desktop) return LayoutType.tablet;
    return LayoutType.desktop;
  }

  static bool isPhone(Size size) => size.shortestSide < tablet;
  static bool isTablet(Size size) =>
      size.shortestSide >= tablet && size.width < desktop;
  static bool isDesktop(Size size) => size.width >= desktop;
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
