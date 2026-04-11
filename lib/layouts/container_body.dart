import 'package:flutter/widgets.dart';

import '../constants/breakpoints.dart';

/// Constrains [child] to a layout-aware maximum width and centers it —
/// mirrors Tailwind's `container mx-auto` pattern used in the React client.
///
/// Max-width thresholds (width-based, mirrors Tailwind min-width):
/// - width < 768   → unconstrained (full width)
/// - width < 1024  → [Breakpoints.md]  (768px)
/// - width ≥ 1024  → [Breakpoints.xxl] (1536px)
///
/// Usage:
/// ```dart
/// ContainerBody(child: myScrollView)
/// ```
class ContainerBody extends StatelessWidget {
  const ContainerBody({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    // Width-only thresholds — mirrors Tailwind's min-width container behaviour.
    // shortestSide is intentionally not used here (see _buildGrid for reasoning).
    final maxWidth = width >= Breakpoints.lg
        ? Breakpoints.xxl
        : width >= Breakpoints.md
            ? Breakpoints.md
            : double.infinity;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
