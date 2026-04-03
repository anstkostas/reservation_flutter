import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../constants/breakpoints.dart';
import '../../cubits/restaurants/restaurant_cubit.dart';
import '../../models/models.dart';
import '../../widgets/error_display.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/restaurants/restaurant_card.dart';

/// Displays all restaurants in a responsive grid.
///
/// Calls [RestaurantCubit.fetchAll] on mount. Uses [buildWhen] to ignore
/// [RestaurantDetailLoaded] emissions — those come from the detail screen
/// which shares the same [RestaurantCubit] instance.
class RestaurantListScreen extends StatefulWidget {
  const RestaurantListScreen({super.key});

  @override
  State<RestaurantListScreen> createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RestaurantCubit>().fetchAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Restaurants')),
      body: BlocBuilder<RestaurantCubit, RestaurantState>(
        // Ignore RestaurantDetailLoaded — emitted by the detail screen using the
        // same cubit. Without this, navigating to a detail view would clear the list.
        buildWhen: (_, current) => current is! RestaurantDetailLoaded,
        builder: (context, state) {
          return switch (state) {
            RestaurantInitial() || RestaurantLoading() =>
              const LoadingIndicator(),
            RestaurantFailure(:final message) => ErrorDisplay(
                message: message,
                onRetry: () => context.read<RestaurantCubit>().fetchAll(),
              ),
            RestaurantLoaded(:final restaurants) when restaurants.isEmpty =>
              const Center(child: Text('No restaurants available.')),
            RestaurantLoaded(:final restaurants) => _buildGrid(restaurants),
            // RestaurantDetailLoaded is excluded by buildWhen — never reached.
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }

  Widget _buildGrid(List<RestaurantModel> restaurants) {
    final size = MediaQuery.sizeOf(context);
    final crossAxisCount = switch (Breakpoints.layoutOf(size)) {
      LayoutType.phone => 1,
      LayoutType.tablet => 2,
      LayoutType.desktop => 3,
    };

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: restaurants.length,
      itemBuilder: (context, index) => RestaurantCard(
        restaurant: restaurants[index],
        onTap: () => context.go('/restaurants/${restaurants[index].id}'),
      ),
    );
  }
}
