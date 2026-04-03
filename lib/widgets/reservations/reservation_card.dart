import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/models.dart';
import 'reservation_status_badge.dart';

/// A card showing a summary of a single reservation.
///
/// Used in [ReservationHistoryScreen]'s tab lists. [onTap] typically opens
/// [ReservationDetailSheet] for the tapped reservation.
class ReservationCard extends StatelessWidget {
  const ReservationCard({
    super.key,
    required this.reservation,
    required this.onTap,
  });

  final ReservationModel reservation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat.yMMMd().format(reservation.scheduledAt);
    final time = DateFormat.Hm().format(reservation.scheduledAt);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      reservation.restaurantName ?? 'Restaurant',
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
            ],
          ),
        ),
      ),
    );
  }
}
