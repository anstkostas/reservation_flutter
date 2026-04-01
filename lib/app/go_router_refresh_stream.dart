import 'dart:async';

import 'package:flutter/foundation.dart';

/// Bridges a [Stream] to [ChangeNotifier] so GoRouter's `refreshListenable`
/// can react to BLoC/Cubit state changes.
///
/// GoRouter's redirect logic only re-runs when its `refreshListenable` fires.
/// BLoC and Cubit expose a [Stream], not a [ChangeNotifier], so this adapter
/// is needed to connect them.
///
/// ## Usage
///
/// ```dart
/// GoRouter(
///   refreshListenable: GoRouterRefreshStream(authBloc.stream),
///   redirect: (context, state) {
///     final authState = context.read<AuthBloc>().state;
///     if (authState is AuthUnauthenticated) return '/login';
///     if (authState is AuthAuthenticated) return '/';
///     return null; // no redirect
///   },
/// )
/// ```
///
/// Every emission from [AuthBloc.stream] calls [notifyListeners], which
/// triggers GoRouter to re-evaluate its redirect — routing to `/login` on
/// [AuthUnauthenticated] and to `/` on [AuthAuthenticated].
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
