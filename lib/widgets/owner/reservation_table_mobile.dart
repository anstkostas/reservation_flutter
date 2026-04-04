import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../constants/reservation_status.dart';
import '../../cubits/reservations/owner/owner_reservation_cubit.dart';
import '../../models/models.dart';
import '../reservations/reservation_status_badge.dart';
import 'resolve_dialog.dart';

/// Mobile card list view of the owner's reservations.
///
/// Renders a [ListView] of cards showing customer name, date, time, people,
/// and status. Active reservations include a Resolve button.
class ReservationTableMobile extends StatelessWidget {
  const ReservationTableMobile({super.key, required this.reservations});

  final List<ReservationModel> reservations;

  @override
  Widget build(BuildContext context) {
    if (reservations.isEmpty) {
      return const Center(child: Text('No reservations yet.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: reservations.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _buildCard(context, reservations[index]),
    );
  }

  Widget _buildCard(BuildContext context, ReservationModel reservation) {
    final date = DateFormat.yMMMd().format(reservation.scheduledAt.toLocal());
    final time = DateFormat.Hm().format(reservation.scheduledAt.toLocal());
    final customerName = reservation.customer != null
        ? '${reservation.customer!.firstname} ${reservation.customer!.lastname}'
        : '—';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    customerName,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ReservationStatusBadge(status: reservation.status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 6),
                Text(date, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 6),
                Text(time, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(width: 16),
                const Icon(Icons.person, size: 16),
                const SizedBox(width: 6),
                Text(
                  '${reservation.people}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            if (reservation.status == ReservationStatus.active) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: () => _showResolveDialog(context, reservation),
                  child: const Text('Resolve'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showResolveDialog(
    BuildContext context,
    ReservationModel reservation,
  ) async {
    // Capture cubit before the async gap — context may be stale after await.
    final cubit = context.read<OwnerReservationCubit>();
    final result = await ResolveDialog.show(context);
    if (result != null) {
      await cubit.resolve(id: reservation.id, status: result);
    }
  }
}
