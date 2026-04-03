import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constants/user_role.dart';
import '../../cubits/auth/auth_bloc.dart';
import '../../cubits/restaurants/restaurant_cubit.dart';
import '../../models/models.dart';
import '../../widgets/error_display.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/reservations/reservation_create_sheet.dart';

/// Shows full details for a single restaurant.
///
/// Calls [RestaurantCubit.fetchById] on mount using [restaurantId] from the
/// route. Uses [buildWhen] to ignore [RestaurantLoaded] emissions — those come
/// from the list screen which shares the same [RestaurantCubit] instance.
///
/// The "Make Reservation" button is only rendered for authenticated customers —
/// owners and unauthenticated users see nothing in its place.
class RestaurantDetailScreen extends StatefulWidget {
  const RestaurantDetailScreen({super.key, required this.restaurantId});

  final String restaurantId;

  @override
  State<RestaurantDetailScreen> createState() =>
      _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RestaurantCubit>().fetchById(widget.restaurantId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<RestaurantCubit, RestaurantState>(
        // Ignore RestaurantLoaded — emitted by the list screen using the same
        // cubit. Without this, the list refreshing would wipe the detail view.
        buildWhen: (_, current) => current is! RestaurantLoaded,
        builder: (context, state) {
          return switch (state) {
            RestaurantInitial() || RestaurantLoading() =>
              const LoadingIndicator(),
            RestaurantFailure(:final message) => ErrorDisplay(
                message: message,
                onRetry: () => context
                    .read<RestaurantCubit>()
                    .fetchById(widget.restaurantId),
              ),
            RestaurantDetailLoaded(:final restaurant) =>
              _buildDetail(restaurant),
            // RestaurantLoaded is excluded by buildWhen — never reached.
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }

  Widget _buildDetail(RestaurantModel restaurant) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 240,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(restaurant.name),
            background: CachedNetworkImage(
              imageUrl: restaurant.coverImageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  const ColoredBox(color: Colors.black26),
              errorWidget: (context, url, error) => const ColoredBox(
                color: Colors.black26,
                child: Center(
                  child: Icon(
                    Icons.restaurant,
                    size: 60,
                    color: Colors.white54,
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: restaurant.logoUrl,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const ColoredBox(color: Colors.black12),
                        errorWidget: (context, url, error) => const SizedBox(
                          width: 64,
                          height: 64,
                          child: Icon(Icons.restaurant),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Chip(
                      avatar: const Icon(Icons.table_restaurant, size: 16),
                      label: Text('${restaurant.capacity} tables'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'About',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  restaurant.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                _buildReservationButton(restaurant.id),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Renders "Make Reservation" only for authenticated customers.
  ///
  /// Owners see their own dashboard; unauthenticated users cannot book.
  Widget _buildReservationButton(String restaurantId) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isCustomer = state is AuthAuthenticated &&
            state.user.role == UserRole.customer;
        if (!isCustomer) return const SizedBox.shrink();

        return FilledButton.icon(
          onPressed: () => ReservationCreateSheet.show(context, restaurantId),
          icon: const Icon(Icons.calendar_today),
          label: const Text('Make Reservation'),
        );
      },
    );
  }
}
