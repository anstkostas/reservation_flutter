import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constants/breakpoints.dart';
import '../../cubits/reservations/owner/owner_reservation_cubit.dart';
import '../../widgets/error_display.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/owner/reservation_table.dart';
import '../../widgets/owner/reservation_table_mobile.dart';

/// The owner's main screen — shows all reservations for their restaurant.
///
/// Fetches reservations on mount. [ResponsiveLayout] renders [ReservationTable]
/// on desktop/tablet and [ReservationTableMobile] on phone.
class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OwnerReservationCubit>().fetchOwner();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reservations')),
      body: BlocConsumer<OwnerReservationCubit, OwnerReservationState>(
        // Only trigger the snackbar on action success — failures surface inside
        // the resolve dialog at the cubit level (OwnerReservationFailure).
        listenWhen: (_, current) => current is OwnerReservationActionSuccess,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reservation resolved.')),
          );
        },
        // Skip the ActionSuccess state — it lasts one frame before the cubit
        // emits OwnerReservationLoaded with fresh data.
        buildWhen: (_, current) => current is! OwnerReservationActionSuccess,
        builder: (context, state) {
          return switch (state) {
            OwnerReservationInitial() ||
            OwnerReservationLoading() =>
              const LoadingIndicator(),
            OwnerReservationFailure(:final message) => ErrorDisplay(
              message: message,
              onRetry: () =>
                  context.read<OwnerReservationCubit>().fetchOwner(),
            ),
            OwnerReservationLoaded(:final reservations) => ResponsiveLayout(
              phone: ReservationTableMobile(reservations: reservations),
              desktop: ReservationTable(reservations: reservations),
            ),
            // ActionSuccess filtered by buildWhen — never reached.
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}
