import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../constants/reservation_status.dart';
import '../../cubits/reservations/owner/owner_reservation_cubit.dart';
import '../../models/models.dart';
import '../reservations/reservation_status_badge.dart';

/// Mobile card list view of the owner's reservations.
///
/// Renders a [ListView] of cards. Each card shows customer name + email,
/// date, time, people (as icon chips), status badge, and — when [showActions]
/// is true and the scheduled time has passed — inline Complete / No-show buttons.
class ReservationTableMobile extends StatelessWidget {
  const ReservationTableMobile({
    super.key,
    required this.reservations,
    required this.showActions,
  });

  final List<ReservationModel> reservations;
  final bool showActions;

  /// Returns true when the scheduled time has arrived or passed.
  bool _canUpdate(DateTime scheduledAt) =>
      !scheduledAt.isAfter(DateTime.now());

  @override
  Widget build(BuildContext context) {
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
                  .withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              'No reservations found.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: reservations.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) =>
          _buildCard(context, reservations[index]),
    );
  }

  Widget _buildCard(BuildContext context, ReservationModel reservation) {
    final date = DateFormat.yMMMd().format(reservation.scheduledAt.toLocal());
    final time = DateFormat.Hm().format(reservation.scheduledAt.toLocal());
    final customerName = reservation.customer != null
        ? '${reservation.customer!.firstname} ${reservation.customer!.lastname}'
        : '—';
    final customerEmail = reservation.customer?.email ?? '';
    final canUpdate = _canUpdate(reservation.scheduledAt);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: customer name + email | status badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customerName,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (customerEmail.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          customerEmail,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ReservationStatusBadge(status: reservation.status),
              ],
            ),

            const SizedBox(height: 12),

            // Data chips — 2-column grid: date | time, then people full width
            Row(
              children: [
                Expanded(child: _InfoChip(icon: Icons.calendar_today, label: date)),
                const SizedBox(width: 8),
                Expanded(child: _InfoChip(icon: Icons.access_time, label: time)),
              ],
            ),
            const SizedBox(height: 8),
            _InfoChip(
              icon: Icons.people,
              label: '${reservation.people} People',
              fullWidth: true,
            ),

            // Actions
            if (showActions) ...[
              const SizedBox(height: 12),
              if (canUpdate)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _resolve(
                          context,
                          reservation.id,
                          ReservationStatus.completed,
                        ),
                        icon: const Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: Colors.green,
                        ),
                        label: const Text(
                          'Complete',
                          style: TextStyle(color: Colors.green),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.green),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _resolve(
                          context,
                          reservation.id,
                          ReservationStatus.noShow,
                        ),
                        icon: const Icon(
                          Icons.cancel_outlined,
                          size: 16,
                          color: Colors.red,
                        ),
                        label: const Text(
                          'No-show',
                          style: TextStyle(color: Colors.red),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                )
              else
                Center(
                  child: Text(
                    'Arriving soon',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                        ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  /// Captures the cubit before firing — avoids stale context after async gap.
  void _resolve(BuildContext context, String id, ReservationStatus status) {
    final cubit = context.read<OwnerReservationCubit>();
    cubit.resolve(id: id, status: status);
  }
}

/// A small labelled chip used to display a single reservation data point.
///
/// Renders an icon + label inside a rounded container with a muted background,
/// matching the React mobile card's `bg-muted/50 rounded-md` info tiles.
class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    this.fullWidth = false,
  });

  final IconData icon;
  final String label;

  /// When true the chip expands to fill its parent's width.
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
