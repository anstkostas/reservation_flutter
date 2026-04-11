import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constants/breakpoints.dart';
import '../../constants/reservation_status.dart';
import '../../cubits/reservations/owner/owner_reservation_cubit.dart';
import '../../layouts/app_navbar.dart';
import '../../models/models.dart';
import '../../widgets/error_display.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/owner/reservation_table.dart';
import '../../widgets/owner/reservation_table_mobile.dart';

/// The owner's main dashboard — shows all reservations for their restaurant.
///
/// Fetches reservations on mount. Supports:
/// - **Tabs:** Active (upcoming, sorted ASC) and History (past, sorted DESC).
/// - **Search:** Client-side filter by customer name or email, scoped to the
///   current tab's visible list.
/// - **Responsive layout:** Search field sits to the right of the header on
///   tablet/desktop and spans full width below the title on phone.
class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  final _searchController = TextEditingController();
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    context.read<OwnerReservationCubit>().fetchOwner();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Filters [reservations] by customer name or email against [_searchTerm].
  List<ReservationModel> _filter(List<ReservationModel> reservations) {
    if (_searchTerm.isEmpty) return reservations;
    final term = _searchTerm.toLowerCase();
    return reservations.where((r) {
      final name =
          '${r.customer?.firstname ?? ''} ${r.customer?.lastname ?? ''}'
              .toLowerCase();
      final email = (r.customer?.email ?? '').toLowerCase();
      return name.contains(term) || email.contains(term);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppNavbar(
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: BlocBuilder<OwnerReservationCubit, OwnerReservationState>(
              buildWhen: (_, current) =>
                  current is! OwnerReservationActionSuccess,
              builder: (context, state) {
                // Compute tab counts from filtered data so they stay in sync
                // with the search field even between BLoC state changes.
                final all = state is OwnerReservationLoaded
                    ? _filter(state.reservations)
                    : <ReservationModel>[];
                final activeCount = all
                    .where((r) => r.status == ReservationStatus.active)
                    .length;
                final historyCount = all
                    .where((r) => r.status != ReservationStatus.active)
                    .length;

                return TabBar(
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 6),
                          Text('Active ($activeCount)'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.history, size: 16),
                          const SizedBox(width: 6),
                          Text('History ($historyCount)'),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        body: BlocConsumer<OwnerReservationCubit, OwnerReservationState>(
            listenWhen: (_, current) =>
                current is OwnerReservationActionSuccess,
            listener: (context, state) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reservation resolved.')),
              );
            },
            buildWhen: (_, current) =>
                current is! OwnerReservationActionSuccess,
            builder: (context, state) {
              return switch (state) {
                OwnerReservationInitial() ||
                OwnerReservationLoading() => const LoadingIndicator(),
                OwnerReservationFailure(:final message) => ErrorDisplay(
                  message: message,
                  onRetry: () =>
                      context.read<OwnerReservationCubit>().fetchOwner(),
                ),
                OwnerReservationLoaded(:final reservations) => _buildContent(
                  reservations,
                ),
                // ActionSuccess filtered by buildWhen — never reached.
                _ => const SizedBox.shrink(),
              };
            },
          ),
      ),
    );
  }

  Widget _buildContent(List<ReservationModel> reservations) {
    final filtered = _filter(reservations);

    final active =
        filtered.where((r) => r.status == ReservationStatus.active).toList()
          ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    final history =
        filtered.where((r) => r.status != ReservationStatus.active).toList()
          ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

    final isPhone =
        Breakpoints.layoutOf(MediaQuery.sizeOf(context)) == LayoutType.phone;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: isPhone
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleBlock(),
                    const SizedBox(height: 12),
                    _buildSearchField(),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: _buildTitleBlock()),
                    const SizedBox(width: 16),
                    SizedBox(width: 280, child: _buildSearchField()),
                  ],
                ),
        ),
        Expanded(
          child: TabBarView(
            children: [
              _buildTabContent(active, showActions: true, isPhone: isPhone),
              _buildTabContent(history, showActions: false, isPhone: isPhone),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitleBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dashboard',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          "Manage your restaurant's reservations.",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _searchTerm = value),
      decoration: InputDecoration(
        hintText: 'Search by name or email...',
        prefixIcon: const Icon(Icons.search, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        isDense: true,
      ),
    );
  }

  Widget _buildTabContent(
    List<ReservationModel> reservations, {
    required bool showActions,
    required bool isPhone,
  }) {
    if (isPhone) {
      return ReservationTableMobile(
        reservations: reservations,
        showActions: showActions,
      );
    }
    return ReservationTable(
      reservations: reservations,
      showActions: showActions,
    );
  }
}
