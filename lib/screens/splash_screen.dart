import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../app/design_tokens.dart';
import '../constants/user_role.dart';
import '../cubits/auth/auth_bloc.dart';
import '../layouts/app_navbar.dart';

/// Full-screen hero landing page — mirrors React's SplashPage.
///
/// Shows the app name, subtitle, and a smart CTA whose label and destination
/// depend on auth state: unauthenticated → /restaurants; customer → /reservations;
/// owner → /owner. Accessible without authentication.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppNavbar(),
      body: BlocBuilder<AuthBloc, AuthState>(
        buildWhen: (prev, curr) =>
            prev.runtimeType != curr.runtimeType ||
            (prev is AuthAuthenticated &&
                curr is AuthAuthenticated &&
                prev.user != curr.user),
        builder: (context, authState) {
          final user = authState is AuthAuthenticated ? authState.user : null;

          return Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                'https://images.unsplash.com/photo-1705211734796-7cdbcb527636?w=600&auto=format&fit=crop&q=60',
                fit: BoxFit.cover,
                errorBuilder: (_, _, e) =>
                    const ColoredBox(color: Colors.black87),
              ),
              // Dark gradient — lighter at top, heavier at bottom.
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.45),
                      Colors.black.withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Reservation App',
                          style: Theme.of(context).textTheme.displayLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.w800,
                                shadows: const [
                                  Shadow(blurRadius: 16, color: Colors.black54),
                                ],
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Book, manage, and explore your favorite restaurants seamlessly.',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Colors.grey[200],
                                fontWeight: FontWeight.w300,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        FilledButton(
                          onPressed: () {
                            if (user == null) {
                              context.go('/restaurants');
                            } else if (user.role == UserRole.owner) {
                              context.go('/owner');
                            } else {
                              context.go('/reservations');
                            }
                          },
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                            ),
                            textStyle: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          child: Text(
                            user == null
                                ? 'Explore Restaurants'
                                : user.role == UserRole.owner
                                ? 'Dashboard'
                                : 'My Reservations',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
