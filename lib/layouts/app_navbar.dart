import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../constants/breakpoints.dart';
import '../constants/user_role.dart';
import '../cubits/auth/auth_bloc.dart';
import '../layouts/container_body.dart';
import '../models/models.dart';

/// Global navigation bar — mirrors the React web client layout.
///
/// Structure (all screen sizes):
/// - Left: app logo — tappable, navigates to /restaurants
/// - Centre: Restaurants link — active-state highlight when on /restaurants
/// - Right: user avatar + dropdown (authenticated) or Log-in button (unauthenticated)
///
/// The Log-in button is hidden on /login to avoid redundancy.
class AppNavbar extends StatelessWidget implements PreferredSizeWidget {
  const AppNavbar({super.key, this.bottom});

  /// Optional widget shown below the toolbar (e.g. a [TabBar]).
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      // Only rebuild when auth status changes or the authenticated user changes.
      buildWhen: (prev, curr) =>
          prev.runtimeType != curr.runtimeType ||
          (prev is AuthAuthenticated &&
              curr is AuthAuthenticated &&
              prev.user != curr.user),
      builder: (context, authState) {
        final user = authState is AuthAuthenticated ? authState.user : null;
        final location = GoRouterState.of(context).matchedLocation;
        final isLoginPage = location == '/login';

        return AppBar(
          automaticallyImplyLeading: false,
          leadingWidth: 0,
          titleSpacing: 0,
          // scrolledUnderElevation gives a subtle visual separator when content
          // scrolls under the bar — Flutter-native alternative to border-b.
          scrolledUnderElevation: 1,
          bottom: bottom,
          title: ContainerBody(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                spacing: 8,
                children: [
                  const _LogoButton(),
                  const _RestaurantsLink(),
                  if (user != null)
                    _UserMenuButton(user: user)
                  else if (!isLoginPage)
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Log in'),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LogoButton extends StatelessWidget {
  const _LogoButton();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go('/'),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: SvgPicture.asset('assets/logo.svg', width: 28, height: 28),
      ),
    );
  }
}

class _RestaurantsLink extends StatelessWidget {
  const _RestaurantsLink();

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final isActive = location.startsWith('/restaurants');

    return TextButton.icon(
      onPressed: () => context.go('/restaurants'),
      icon: const Icon(Icons.restaurant_menu, size: 18),
      label: const Text('Restaurants'),
      style: TextButton.styleFrom(
        foregroundColor: isActive
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
      ),
    );
  }
}

class _UserMenuButton extends StatelessWidget {
  const _UserMenuButton({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final initial = user.firstname.isNotEmpty
        ? user.firstname[0].toUpperCase()
        : '?';

    final colorScheme = Theme.of(context).colorScheme;
    final iconSize = Breakpoints.isDesktop(MediaQuery.sizeOf(context)) ? 18.0 : 16.0;

    return PopupMenuButton<String>(
      offset: const Offset(0, 44),
      constraints: const BoxConstraints(minWidth: 224),
      // Match app background — prevents the elevated surfaceContainer default
      color: colorScheme.surface,
      onSelected: (value) {
        if (value == 'nav') {
          context.go(user.role == UserRole.owner ? '/owner' : '/reservations');
        } else if (value == 'logout') {
          context.read<AuthBloc>().add(const AuthLogoutRequested());
        }
      },
      itemBuilder: (menuContext) => [
        // User info header — non-interactive
        PopupMenuItem<String>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${user.firstname} ${user.lastname}',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                user.email,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.role.name.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'nav',
          child: Row(
            children: [
              Icon(
                user.role == UserRole.owner
                    ? Icons.dashboard
                    : Icons.calendar_today,
                size: iconSize,
              ),
              const SizedBox(width: 8),
              Text(
                user.role == UserRole.owner ? 'Dashboard' : 'Reservations',
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: iconSize, color: colorScheme.error),
              const SizedBox(width: 8),
              Text('Logout', style: TextStyle(color: colorScheme.error)),
            ],
          ),
        ),
      ],
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // Matches Shadcn AvatarFallback: bg-muted + border border-primary/20
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Center(
          child: Text(
            initial,
            style: TextStyle(
              // Matches Shadcn text-muted-foreground
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
