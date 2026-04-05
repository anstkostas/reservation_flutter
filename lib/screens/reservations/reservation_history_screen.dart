import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../constants/breakpoints.dart';
import '../../constants/reservation_status.dart';
import '../../cubits/reservations/customer/customer_reservation_cubit.dart';
import '../../models/models.dart';
import '../../widgets/error_display.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/reservations/reservation_card.dart';
import '../../layouts/app_navbar.dart';
import '../../widgets/reservations/reservation_detail_sheet.dart';

/// Displays the authenticated customer's reservations in two tabs: Upcoming and History.
///
/// Calls [CustomerReservationCubit.fetchMine] on mount. Tab labels show live
/// reservation counts. Upcoming sorted ASC (soonest first); History sorted DESC.
/// Mutations triggered from [ReservationDetailSheet] automatically refresh the list.
class ReservationHistoryScreen extends StatefulWidget {
  const ReservationHistoryScreen({super.key});

  @override
  State<ReservationHistoryScreen> createState() =>
      _ReservationHistoryScreenState();
}

class _ReservationHistoryScreenState extends State<ReservationHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CustomerReservationCubit>().fetchMine();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppNavbar(
          // Wrap in PreferredSize so BlocBuilder can provide dynamic tab counts.
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: BlocBuilder<CustomerReservationCubit, CustomerReservationState>(
              buildWhen: (_, current) =>
                  current is! CustomerReservationActionSuccess,
              builder: (context, state) {
                final active = state is CustomerReservationLoaded
                    ? state.reservations
                        .where((r) => r.status == ReservationStatus.active)
                        .length
                    : 0;
                final past = state is CustomerReservationLoaded
                    ? state.reservations
                        .where((r) => r.status != ReservationStatus.active)
                        .length
                    : 0;
                return TabBar(
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 6),
                          Text('Upcoming ($active)'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.history, size: 16),
                          const SizedBox(width: 6),
                          Text('History ($past)'),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        body: BlocConsumer<CustomerReservationCubit, CustomerReservationState>(
          listenWhen: (_, current) =>
              current is CustomerReservationActionSuccess,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Reservation updated.')),
            );
          },
          buildWhen: (_, current) =>
              current is! CustomerReservationActionSuccess,
          builder: (context, state) {
            return switch (state) {
              CustomerReservationInitial() ||
              CustomerReservationLoading() =>
                const LoadingIndicator(),
              CustomerReservationFailure(:final message) => ErrorDisplay(
                  message: message,
                  onRetry: () =>
                      context.read<CustomerReservationCubit>().fetchMine(),
                ),
              CustomerReservationLoaded(:final reservations) =>
                _buildContent(reservations),
              // CustomerReservationActionSuccess filtered by buildWhen — never reached.
              _ => const SizedBox.shrink(),
            };
          },
        ),
      ),
    );
  }

  Widget _buildContent(List<ReservationModel> reservations) {
    final active = reservations
        .where((r) => r.status == ReservationStatus.active)
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    final past = reservations
        .where((r) => r.status != ReservationStatus.active)
        .toList()
      ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Reservations',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'View and manage your dining bookings.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () => context.go('/restaurants'),
                icon: const Icon(Icons.restaurant_menu, size: 16),
                label: const Text('Book a Table'),
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            children: [
              _buildGrid(
                active,
                emptyMessage: 'No upcoming reservations',
                emptyDetail:
                    "You don't have any active bookings at the moment. Explore restaurants and book your next meal!",
              ),
              _buildGrid(
                past,
                emptyMessage: 'No past reservations',
                emptyDetail: 'No reservation history yet.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGrid(
    List<ReservationModel> reservations, {
    required String emptyMessage,
    required String emptyDetail,
  }) {
    if (reservations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.restaurant_menu,
                  size: 32,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.4),
                ),
                const SizedBox(height: 12),
                Text(
                  emptyMessage,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  emptyDetail,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final size = MediaQuery.sizeOf(context);
    // Phone: list (natural card height); tablet/desktop: 2/3-column grid.
    final layout = Breakpoints.layoutOf(size);

    if (layout == LayoutType.phone) {
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: reservations.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) => ReservationCard(
          reservation: reservations[index],
          onTap: () =>
              ReservationDetailSheet.show(context, reservations[index]),
        ),
      );
    }

    final crossAxisCount = layout == LayoutType.tablet ? 2 : 3;
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 3.0,
      ),
      itemCount: reservations.length,
      itemBuilder: (context, index) => ReservationCard(
        reservation: reservations[index],
        onTap: () =>
            ReservationDetailSheet.show(context, reservations[index]),
      ),
    );
  }
}
