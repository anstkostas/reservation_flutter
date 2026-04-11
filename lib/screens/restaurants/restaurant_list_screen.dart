import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../constants/breakpoints.dart';
import '../../cubits/restaurants/restaurant_list_cubit.dart';
import '../../models/models.dart';
import '../../widgets/error_display.dart';
import '../../widgets/loading_indicator.dart';
import '../../layouts/app_navbar.dart';
import '../../widgets/restaurants/restaurant_card.dart';

/// Displays all restaurants in a responsive grid.
///
/// Calls [RestaurantListCubit.fetchAll] on mount.
class RestaurantListScreen extends StatefulWidget {
  const RestaurantListScreen({super.key});

  @override
  State<RestaurantListScreen> createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RestaurantListCubit>().fetchAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppNavbar(),
      body: BlocBuilder<RestaurantListCubit, RestaurantListState>(
        builder: (context, state) {
          return switch (state) {
            RestaurantListInitial() ||
            RestaurantListLoading() => const LoadingIndicator(),
            RestaurantListFailure(:final message) => ErrorDisplay(
              message: message,
              onRetry: () => context.read<RestaurantListCubit>().fetchAll(),
            ),
            RestaurantListLoaded(:final restaurants) when restaurants.isEmpty =>
              const Center(child: Text('No restaurants available.')),
            RestaurantListLoaded(:final restaurants) => _buildContent(
              restaurants,
            ),
          };
        },
      ),
    );
  }

  Widget _buildContent(List<RestaurantModel> restaurants) {
    final width = MediaQuery.sizeOf(context).width;
    // Same centering thresholds as ContainerBody — translates the max-width
    // constraint into symmetric padding so the scrollbar can stay full-width.
    final maxWidth = width >= Breakpoints.lg
        ? Breakpoints.xxl
        : width >= Breakpoints.md
            ? Breakpoints.md
            : double.infinity;
    final hPadding = maxWidth.isFinite
        ? ((width - maxWidth) / 2).clamp(0.0, double.infinity) + 16.0
        : 16.0;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(hPadding, 24, hPadding, 8),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Available Restaurants',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 16),
          sliver: _buildGrid(restaurants),
        ),
      ],
    );
  }

  SliverGrid _buildGrid(List<RestaurantModel> restaurants) {
    final size = MediaQuery.sizeOf(context);
    // Width-only breakpoints — mirrors React's md/lg/2xl grid-cols thresholds.
    // layoutOf (shortestSide-based) is intentionally not used here: on web,
    // a narrow browser window height would misclassify tablet widths as phone.
    final crossAxisCount = Breakpoints.is2xl(size)
        ? 4
        : Breakpoints.isDesktop(size)
        ? 3
        : size.width >= Breakpoints.md
        ? 2
        : 1;
    // Matches React's gap-6 (24px) below lg and lg:gap-12 (48px) at lg+.
    final gap = Breakpoints.isDesktop(size) ? 48.0 : 24.0;

    return SliverGrid.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: gap,
        crossAxisSpacing: gap,
        mainAxisExtent: 362,
      ),
      itemCount: restaurants.length,
      itemBuilder: (context, index) => RestaurantCard(
        restaurant: restaurants[index],
        onTap: () => context.go('/restaurants/${restaurants[index].id}'),
      ),
    );
  }
}
