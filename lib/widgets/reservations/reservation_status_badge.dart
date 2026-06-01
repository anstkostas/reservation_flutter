import 'package:flutter/material.dart';

import '../../constants/reservation_status.dart';
import '../../l10n/app_localizations.dart';

/// A compact [Chip] showing a reservation's status with a colour indicator.
class ReservationStatusBadge extends StatelessWidget {
  const ReservationStatusBadge({super.key, required this.status});

  final ReservationStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final label = switch (status) {
      ReservationStatus.active => l10n.statusActive,
      ReservationStatus.canceled => l10n.statusCanceled,
      ReservationStatus.completed => l10n.statusCompleted,
      ReservationStatus.noShow => l10n.statusNoShow,
    };
    final color = switch (status) {
      ReservationStatus.active => Colors.green,
      ReservationStatus.canceled => Colors.grey,
      ReservationStatus.completed => Theme.of(context).colorScheme.primary,
      ReservationStatus.noShow => Colors.red,
    };

    return Chip(
      label: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
      backgroundColor: color.withAlpha(38),
      side: BorderSide(color: color),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }
}
