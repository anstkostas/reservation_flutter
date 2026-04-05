import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../constants/user_role.dart';
import '../cubits/auth/auth_bloc.dart';
import '../cubits/restaurants/restaurant_cubit.dart';
import '../cubits/restaurants/restaurant_detail_cubit.dart';
import '../screens/auth/login_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/loading_screen.dart';
import '../screens/owner/owner_dashboard_screen.dart';
import '../screens/reservations/reservation_history_screen.dart';
import '../screens/restaurants/restaurant_detail_screen.dart';
import '../screens/restaurants/restaurant_list_screen.dart';
import 'go_router_refresh_stream.dart';

final _getIt = GetIt.instance;

/// App router — all routes and auth guard in one place.
///
/// [GoRouter.redirect] fires on every navigation event and whenever
/// [GoRouterRefreshStream] notifies a change (i.e. every [AuthState] emission).
/// Auth state changes therefore automatically re-evaluate the guard without
/// manual navigation calls in BlocListeners.
final appRouter = GoRouter(
  initialLocation: '/loading',

  // Re-evaluate redirect on every AuthState change.
  refreshListenable: GoRouterRefreshStream(_getIt<AuthBloc>().stream),

  redirect: _redirect,

  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/loading',
      builder: (context, state) => const LoadingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => BlocProvider(
        // UnownedRestaurantCubit is scoped here — it only exists during signup.
        // Providing it at app level would keep it alive unnecessarily.
        create: (_) => _getIt<UnownedRestaurantCubit>(),
        child: const SignupScreen(),
      ),
    ),
    GoRoute(
      path: '/restaurants',
      builder: (context, state) => const RestaurantListScreen(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) => BlocProvider(
            // RestaurantDetailCubit is scoped to this route — fresh instance
            // per visit so stale data from a previous detail page never bleeds
            // into a new one.
            create: (_) => _getIt<RestaurantDetailCubit>(),
            child: RestaurantDetailScreen(
              restaurantId: state.pathParameters['id']!,
            ),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/reservations',
      builder: (context, state) => const ReservationHistoryScreen(),
    ),
    GoRoute(
      path: '/owner',
      builder: (context, state) => const OwnerDashboardScreen(),
    ),
  ],
);

String? _redirect(BuildContext context, GoRouterState state) {
  final authState = _getIt<AuthBloc>().state;
  final location = state.matchedLocation;

  return switch (authState) {
    // Session check in progress — hold on /loading until AuthBloc resolves.
    AuthInitial() => location == '/loading' ? null : '/loading',

    // Login/signup request in-flight — let the screen handle the loading UI.
    AuthLoading() => null,

    // Login/signup failed — let the screen display the error message.
    AuthFailure() => null,

    // No valid session — allow public routes only; redirect everything else to /login.
    AuthUnauthenticated() => _unauthenticatedRedirect(location),

    // Valid session — bounce away from auth screens; enforce role-based access.
    AuthAuthenticated(:final user) => _authenticatedRedirect(
      location,
      user.role,
    ),
  };
}

/// Allows public routes; redirects protected routes to /login.
String? _unauthenticatedRedirect(String location) {
  // Session check completed with no valid session — land on splash, not login.
  if (location == '/loading') return '/';

  final isPublic =
      location == '/' ||
      location == '/login' ||
      location == '/signup' ||
      location.startsWith('/restaurants');
  return isPublic ? null : '/login';
}

/// Redirects authenticated users away from auth screens and enforces role access.
String? _authenticatedRedirect(String location, UserRole role) {
  // Bounce away from auth/loading screens to the user's home.
  if (location == '/login' || location == '/signup' || location == '/loading') {
    return role == UserRole.customer ? '/restaurants' : '/owner';
  }

  // Customer trying to reach an owner-only route.
  if (location.startsWith('/owner') && role != UserRole.owner) {
    return '/restaurants';
  }

  // Owner trying to reach a customer-only route.
  if (location.startsWith('/reservations') && role != UserRole.customer) {
    return '/owner';
  }

  return null;
}
