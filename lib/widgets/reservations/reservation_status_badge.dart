import 'package:flutter/material.dart';

import '../../constants/reservation_status.dart';

/// A compact [Chip] showing a reservation's status with a colour indicator.
class ReservationStatusBadge extends StatelessWidget {
  const ReservationStatusBadge({super.key, required this.status});

  final ReservationStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      ReservationStatus.active => ('Active', Colors.green),
      ReservationStatus.canceled => ('Canceled', Colors.grey),
      ReservationStatus.completed => (
        'Completed',
        Theme.of(context).colorScheme.primary,
      ),
      ReservationStatus.noShow => ('No-show', Colors.red),
    };

    return Chip(
      label: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
      // withAlpha(38) ≈ 15% opacity — avoids the deprecated withOpacity()
      backgroundColor: color.withAlpha(38),
      side: BorderSide(color: color),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }
}
