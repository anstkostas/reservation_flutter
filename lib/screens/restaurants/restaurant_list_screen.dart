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
            RestaurantListInitial() || RestaurantListLoading() =>
              const LoadingIndicator(),
            RestaurantListFailure(:final message) => ErrorDisplay(
                message: message,
                onRetry: () => context.read<RestaurantListCubit>().fetchAll(),
              ),
            RestaurantListLoaded(:final restaurants) when restaurants.isEmpty =>
              const Center(child: Text('No restaurants available.')),
            RestaurantListLoaded(:final restaurants) =>
              _buildContent(restaurants),
          };
        },
      ),
    );
  }

  Widget _buildContent(List<RestaurantModel> restaurants) {
    final layout = Breakpoints.layoutOf(MediaQuery.sizeOf(context));
    final hPadding = switch (layout) {
      LayoutType.phone => 16.0,
      LayoutType.tablet => 24.0,
      LayoutType.desktop => 32.0,
    };

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(hPadding, 24, hPadding, 8),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Available Restaurants',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 16),
          sliver: _buildGrid(restaurants, layout),
        ),
      ],
    );
  }

  SliverGrid _buildGrid(List<RestaurantModel> restaurants, LayoutType layout) {
    final size = MediaQuery.sizeOf(context);
    final crossAxisCount = Breakpoints.is2xl(size) ? 4 : switch (layout) {
      LayoutType.phone => 1,
      LayoutType.tablet => 2,
      LayoutType.desktop => 3,
    };
    // Matches React's gap-6 (24px) on mobile/tablet and lg:gap-12 (48px) on desktop.
    final gap = switch (layout) {
      LayoutType.phone => 24.0,
      LayoutType.tablet => 24.0,
      LayoutType.desktop => 48.0,
    };

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
