import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constants/reservation_status.dart';
import '../../cubits/reservations/customer/customer_reservation_cubit.dart';
import '../../models/models.dart';
import '../../widgets/error_display.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/reservations/reservation_card.dart';
import '../../widgets/reservations/reservation_detail_sheet.dart';

/// Displays the authenticated customer's reservations in two tabs: Active and Past.
///
/// Calls [CustomerReservationCubit.fetchMine] on mount. Mutations triggered
/// from [ReservationDetailSheet] automatically refresh the list — the cubit
/// re-fetches after every create, update, and cancel.
class ReservationHistoryScreen extends StatefulWidget {
  const ReservationHistoryScreen({super.key});

  @override
  State<ReservationHistoryScreen> createState() =>
      _ReservationHistoryScreenState();
}

class _ReservationHistoryScreenState extends State<ReservationHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CustomerReservationCubit>().fetchMine();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Reservations'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Active'), Tab(text: 'Past')],
          ),
        ),
        body: BlocConsumer<CustomerReservationCubit, CustomerReservationState>(
          // Only trigger the snackbar listener on action success — failures are
          // handled inside the sheet that triggered the mutation.
          listenWhen: (_, current) =>
              current is CustomerReservationActionSuccess,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Reservation updated.')),
            );
          },
          // Don't rebuild the list on CustomerReservationActionSuccess — it
          // lasts only one frame before the cubit emits CustomerReservationLoaded.
          buildWhen: (_, current) =>
              current is! CustomerReservationActionSuccess,
          builder: (context, state) {
            return switch (state) {
              CustomerReservationInitial() ||
              CustomerReservationLoading() =>
                const LoadingIndicator(),
              CustomerReservationFailure(:final message) => ErrorDisplay(
                  message: message,
                  onRetry: () =>
                      context.read<CustomerReservationCubit>().fetchMine(),
                ),
              CustomerReservationLoaded(:final reservations) =>
                _buildTabs(reservations),
              // CustomerReservationActionSuccess filtered by buildWhen — never reached.
              _ => const SizedBox.shrink(),
            };
          },
        ),
      ),
    );
  }

  Widget _buildTabs(List<ReservationModel> reservations) {
    final active = reservations
        .where((r) => r.status == ReservationStatus.active)
        .toList();
    final past = reservations
        .where((r) => r.status != ReservationStatus.active)
        .toList();

    return TabBarView(
      children: [
        _buildList(active, emptyMessage: 'You have no active reservations.'),
        _buildList(past, emptyMessage: 'No past reservations.'),
      ],
    );
  }

  Widget _buildList(
    List<ReservationModel> reservations, {
    required String emptyMessage,
  }) {
    if (reservations.isEmpty) {
      return Center(child: Text(emptyMessage));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: reservations.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) => ReservationCard(
        reservation: reservations[index],
        onTap: () =>
            ReservationDetailSheet.show(context, reservations[index]),
      ),
    );
  }
}
