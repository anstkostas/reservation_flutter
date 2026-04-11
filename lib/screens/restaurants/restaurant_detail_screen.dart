import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../constants/breakpoints.dart';
import '../../constants/user_role.dart';
import '../../cubits/auth/auth_bloc.dart';
import '../../cubits/restaurants/restaurant_detail_cubit.dart';
import '../../layouts/app_navbar.dart';
import '../../layouts/container_body.dart';
import '../../models/models.dart';
import '../../widgets/error_display.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/reservations/reservation_create_sheet.dart';

/// Shows full details for a single restaurant.
///
/// Calls [RestaurantDetailCubit.fetchById] on mount using [restaurantId] from
/// the route. The cubit is scoped to this route — a fresh instance is provided
/// by the router on every navigation to `/restaurants/:id`.
///
/// Layout mirrors the React client:
/// - Contained rounded hero image with gradient overlay (name + description)
/// - Responsive grid: About card (2/3) + Reservation card (1/3) at [Breakpoints.md]+;
///   stacked on mobile
/// - Back button overlaid on the hero image on native (non-web) only
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
    context.read<RestaurantDetailCubit>().fetchById(widget.restaurantId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppNavbar(),
      body: BlocBuilder<RestaurantDetailCubit, RestaurantDetailState>(
        builder: (context, state) {
          return switch (state) {
            RestaurantDetailInitial() || RestaurantDetailLoading() =>
              const LoadingIndicator(),
            RestaurantDetailFailure(:final message) => ErrorDisplay(
                message: message,
                onRetry: () => context
                    .read<RestaurantDetailCubit>()
                    .fetchById(widget.restaurantId),
              ),
            RestaurantDetailLoaded(:final restaurant) =>
              _buildDetail(restaurant),
          };
        },
      ),
    );
  }

  Widget _buildDetail(RestaurantModel restaurant) {
    final isWide = MediaQuery.sizeOf(context).width >= Breakpoints.md;

    return SingleChildScrollView(
      child: ContainerBody(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHero(restaurant),
              const SizedBox(height: 32),
              isWide
                  ? _buildWideContent(restaurant)
                  : _buildNarrowContent(restaurant),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero(RestaurantModel restaurant) {
    final heroHeight =
        MediaQuery.sizeOf(context).width >= Breakpoints.md ? 380.0 : 260.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: heroHeight,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
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
            // Bottom-up gradient so name/description text is legible
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black54,
                    Colors.black87,
                  ],
                  stops: [0.4, 0.75, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    restaurant.name,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    restaurant.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
            // Back button overlay — web has browser navigation, native does not
            if (!kIsWeb)
              Positioned(
                top: 12,
                left: 12,
                child: Material(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => context.pop(),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Tablet/desktop: About card (flex 2) + Reservation card (flex 1) side by side.
  Widget _buildWideContent(RestaurantModel restaurant) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _buildAboutCard(restaurant)),
        const SizedBox(width: 24),
        Expanded(flex: 1, child: _buildReservationCard(restaurant.id)),
      ],
    );
  }

  /// Mobile: About card then Reservation card stacked vertically.
  Widget _buildNarrowContent(RestaurantModel restaurant) {
    return Column(
      children: [
        _buildAboutCard(restaurant),
        const SizedBox(height: 16),
        _buildReservationCard(restaurant.id),
      ],
    );
  }

  Widget _buildAboutCard(RestaurantModel restaurant) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('About', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(
              restaurant.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 16),
            Chip(
              avatar: const Icon(Icons.table_restaurant, size: 16),
              label: Text('Capacity: ${restaurant.capacity} Tables'),
            ),
          ],
        ),
      ),
    );
  }

  /// Reservation card — hidden for owners (matches React behaviour).
  ///
  /// Unauthenticated users see the card and are redirected to /login on tap.
  Widget _buildReservationCard(String restaurantId) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isOwner = state is AuthAuthenticated &&
            state.user.role == UserRole.owner;
        if (isOwner) return const SizedBox.shrink();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Make a Reservation',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Secure your table for an unforgettable dining experience.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: state is AuthAuthenticated
                        ? () =>
                            ReservationCreateSheet.show(context, restaurantId)
                        : () => context.go('/login'),
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Book a Table'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
