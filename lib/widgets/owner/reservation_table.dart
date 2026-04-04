import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../constants/reservation_status.dart';
import '../../cubits/reservations/owner/owner_reservation_cubit.dart';
import '../../models/models.dart';
import '../reservations/reservation_status_badge.dart';
import 'resolve_dialog.dart';

/// Desktop/tablet table view of the owner's reservations.
///
/// Renders a [DataTable] with columns: Date, Time, Customer, People, Status,
/// and Action. Only [ReservationStatus.active] rows have a Resolve action —
/// all other rows show an empty cell.
class ReservationTable extends StatelessWidget {
  const ReservationTable({super.key, required this.reservations});

  final List<ReservationModel> reservations;

  @override
  Widget build(BuildContext context) {
    if (reservations.isEmpty) {
      return const Center(child: Text('No reservations yet.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Time')),
          DataColumn(label: Text('Customer')),
          DataColumn(label: Text('People'), numeric: true),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Action')),
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

    return DataRow(
      cells: [
        DataCell(Text(date)),
        DataCell(Text(time)),
        DataCell(Text(customerName)),
        DataCell(Text('${reservation.people}')),
        DataCell(ReservationStatusBadge(status: reservation.status)),
        DataCell(
          reservation.status == ReservationStatus.active
              ? TextButton(
                  onPressed: () => _showResolveDialog(context, reservation),
                  child: const Text('Resolve'),
                )
              : const SizedBox.shrink(),
        ),
      ],
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
