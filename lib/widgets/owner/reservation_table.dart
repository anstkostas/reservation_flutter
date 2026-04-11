import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../constants/reservation_status.dart';
import '../../cubits/reservations/owner/owner_reservation_cubit.dart';
import '../../models/models.dart';
import '../reservations/reservation_status_badge.dart';

/// Desktop/tablet table view of the owner's reservations.
///
/// Renders a [DataTable] with columns: Customer (name + email), Date, Time,
/// People, Status, and (optionally) Actions. [showActions] is false on the
/// History tab. Action buttons are only enabled once [_canUpdate] returns true
/// — i.e. the reservation's scheduled time has passed.
class ReservationTable extends StatelessWidget {
  const ReservationTable({
    super.key,
    required this.reservations,
    required this.showActions,
  });

  final List<ReservationModel> reservations;
  final bool showActions;

  /// Returns true when the scheduled time has arrived or passed.
  bool _canUpdate(DateTime scheduledAt) => !scheduledAt.isAfter(DateTime.now());

  @override
  Widget build(BuildContext context) {
    if (reservations.isEmpty) {
      return Center(
        child: Text(
          'No reservations found.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: DataTable(
        columnSpacing: 20,
        horizontalMargin: 16,
        columns: [
          DataColumn(label: SizedBox(width: 160, child: Text('Customer'))),
          DataColumn(label: SizedBox(width: 110, child: Text('Date'))),
          const DataColumn(label: Text('Time')),
          const DataColumn(label: Text('People')),
          const DataColumn(label: Text('Status')),
          if (showActions) const DataColumn(label: Text('Actions')),
        ],
        rows: reservations.map((r) => _buildRow(context, r)).toList(),
      ),
    );
  }

  DataRow _buildRow(BuildContext context, ReservationModel reservation) {
    final date = DateFormat.yMMMd().format(reservation.scheduledAt.toLocal());
    final time = DateFormat.Hm().format(reservation.scheduledAt.toLocal());
    final customerName = reservation.customer != null
        ? '${reservation.customer!.firstname} ${reservation.customer!.lastname}'
        : '—';
    final customerEmail = reservation.customer?.email ?? '';
    final mutedColor = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.55);

    return DataRow(
      cells: [
        // Customer — name (bold) + email (muted) stacked
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                customerName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              if (customerEmail.isNotEmpty)
                Text(
                  customerEmail,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: mutedColor),
                ),
            ],
          ),
        ),

        // Date with calendar icon
        DataCell(
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: mutedColor),
              const SizedBox(width: 6),
              Flexible(child: Text(date)),
            ],
          ),
        ),

        // Time with clock icon
        DataCell(
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: mutedColor),
              const SizedBox(width: 6),
              Flexible(child: Text(time, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),

        // People with group icon
        DataCell(
          Row(
            children: [
              Icon(Icons.people, size: 14, color: mutedColor),
              const SizedBox(width: 6),
              Text('${reservation.people}'),
            ],
          ),
        ),

        DataCell(ReservationStatusBadge(status: reservation.status)),

        if (showActions)
          DataCell(
            _canUpdate(reservation.scheduledAt)
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Tooltip(
                        message: 'Mark as completed',
                        child: IconButton(
                          onPressed: () => _resolve(
                            context,
                            reservation.id,
                            ReservationStatus.completed,
                          ),
                          icon: const Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      Tooltip(
                        message: 'Mark as no-show',
                        child: IconButton(
                          onPressed: () => _resolve(
                            context,
                            reservation.id,
                            ReservationStatus.noShow,
                          ),
                          icon: const Icon(
                            Icons.cancel_outlined,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  )
                : Text(
                    'Arriving soon',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: mutedColor,
                    ),
                  ),
          ),
      ],
    );
  }

  /// Captures the cubit before firing — avoids stale context after async gap.
  void _resolve(BuildContext context, String id, ReservationStatus status) {
    final cubit = context.read<OwnerReservationCubit>();
    cubit.resolve(id: id, status: status);
  }
}
