import 'package:flutter/material.dart';

import '../../constants/reservation_status.dart';

/// Dialog for resolving a reservation as completed or no-show.
///
/// Used by both [ReservationTable] (desktop) and [ReservationTableMobile] (phone)
/// so the dialog content, wording, and actions are defined in exactly one place.
class ResolveDialog {
  /// Shows the resolve dialog and returns the selected [ReservationStatus],
  /// or `null` if the user dismissed without selecting.
  static Future<ReservationStatus?> show(BuildContext context) {
    return showDialog<ReservationStatus>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Resolve Reservation'),
        content: const Text('Mark this reservation as completed or no-show?'),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context, ReservationStatus.completed),
            child: const Text('Completed'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ReservationStatus.noShow),
            child: const Text('No-show'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
