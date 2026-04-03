import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../constants/user_role.dart';
import '../cubits/auth/auth_bloc.dart';
import 'app_navbar.dart';

/// Nav destination descriptor — decoupled from any specific nav widget.
class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}

const _customerItems = [
  _NavItem(
    label: 'Restaurants',
    icon: Icons.restaurant_menu,
    route: '/restaurants',
  ),
  _NavItem(
    label: 'Reservations',
    icon: Icons.book_online,
    route: '/reservations',
  ),
];

const _ownerItems = [
  _NavItem(label: 'Dashboard', icon: Icons.dashboard, route: '/owner'),
];

/// Adaptive app shell — wraps [child] with role-aware navigation.
///
/// Phone (`< 600px`): [Scaffold] with [BottomNavigationBar].
/// Tablet / desktop (`>= 600px`): [Scaffold] with [NavigationRail] on the left.
///
/// The [title] is shown in the [AppBar] and (on desktop) below the rail logo.
/// Nav items are determined by the authenticated user's role from [AuthBloc].
class AppLayout extends StatelessWidget {
  const AppLayout({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  List<_NavItem> _itemsForRole(UserRole role) =>
      role == UserRole.owner ? _ownerItems : _customerItems;

  int _selectedIndex(List<_NavItem> items, String location) {
    final idx = items.indexWhere((i) => location.startsWith(i.route));
    return idx < 0 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return child;

    final items = _itemsForRole(authState.user.role);
    final location = GoRouterState.of(context).matchedLocation;
    final selectedIndex = _selectedIndex(items, location);
    final size = MediaQuery.sizeOf(context);
    final isPhone = size.shortestSide < 600;

    return isPhone
        ? _PhoneLayout(
            title: title,
            items: items,
            selectedIndex: selectedIndex,
            child: child,
          )
        : _WideLayout(
            title: title,
            items: items,
            selectedIndex: selectedIndex,
            child: child,
          );
  }
}

class _PhoneLayout extends StatelessWidget {
  const _PhoneLayout({
    required this.title,
    required this.items,
    required this.selectedIndex,
    required this.child,
  });

  final String title;
  final List<_NavItem> items;
  final int selectedIndex;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppNavbar(title: title),
      body: child,
      bottomNavigationBar: items.length > 1
          ? BottomNavigationBar(
              currentIndex: selectedIndex,
              onTap: (i) => context.go(items[i].route),
              items: items
                  .map(
                    (item) => BottomNavigationBarItem(
                      icon: Icon(item.icon),
                      label: item.label,
                    ),
                  )
                  .toList(),
            )
          : null, // single-item owners get no bottom bar — just the AppBar
    );
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout({
    required this.title,
    required this.items,
    required this.selectedIndex,
    required this.child,
  });

  final String title;
  final List<_NavItem> items;
  final int selectedIndex;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppNavbar(title: title),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (i) => context.go(items[i].route),
            labelType: NavigationRailLabelType.all,
            destinations: items
                .map(
                  (item) => NavigationRailDestination(
                    icon: Icon(item.icon),
                    label: Text(item.label),
                  ),
                )
                .toList(),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}
