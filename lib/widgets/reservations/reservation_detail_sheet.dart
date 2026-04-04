import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';

import '../../constants/breakpoints.dart';
import '../../constants/reservation_status.dart';
import '../../cubits/reservations/customer/customer_reservation_cubit.dart';
import '../../models/models.dart';
import '../../utils/validators.dart';
import '../app_text_field.dart';
import 'reservation_status_badge.dart';

/// Sheet showing full reservation details with optional inline editing.
///
/// Opened via [ReservationDetailSheet.show]. Active reservations show Edit
/// and Cancel actions. Edit mode shows a pre-filled form; saving dispatches
/// [CustomerReservationCubit.update]. Cancel requires confirmation.
///
/// Closes automatically on [CustomerReservationActionSuccess].
class ReservationDetailSheet extends StatefulWidget {
  const ReservationDetailSheet({super.key, required this.reservation});

  final ReservationModel reservation;

  /// Opens the sheet adaptively based on screen size.
  static void show(BuildContext context, ReservationModel reservation) {
    if (Breakpoints.isPhone(MediaQuery.sizeOf(context))) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => ReservationDetailSheet(reservation: reservation),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          child: SizedBox(
            width: 480,
            child: ReservationDetailSheet(reservation: reservation),
          ),
        ),
      );
    }
  }

  @override
  State<ReservationDetailSheet> createState() => _ReservationDetailSheetState();
}

class _ReservationDetailSheetState extends State<ReservationDetailSheet> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isEditing = false;

  void _onSave() {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;
    final values = _formKey.currentState!.value;

    final date = values['date'] as DateTime;
    final time = values['time'] as DateTime;
    final scheduledAt = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    final people = int.parse(values['people'] as String);

    context.read<CustomerReservationCubit>().update(
      id: widget.reservation.id,
      scheduledAt: scheduledAt,
      people: people,
    );
  }

  void _onCancelConfirmation(BuildContext context) {
    // Capture the cubit before the dialog opens — the dialog's builder
    // context is a new route and may not inherit BlocProvider.
    final cubit = context.read<CustomerReservationCubit>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel reservation?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Keep it'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              cubit.cancel(widget.reservation.id);
            },
            child: Text(
              'Cancel reservation',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CustomerReservationCubit, CustomerReservationState>(
      listener: (context, state) {
        if (state is CustomerReservationActionSuccess) {
          Navigator.of(context).pop();
        }
        if (state is CustomerReservationFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final isLoading = state is CustomerReservationLoading;
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: 24 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: _isEditing
              ? _EditForm(
                  formKey: _formKey,
                  reservation: widget.reservation,
                  isLoading: isLoading,
                  onSave: _onSave,
                  onDiscard: () => setState(() => _isEditing = false),
                )
              : _ViewMode(
                  reservation: widget.reservation,
                  isLoading: isLoading,
                  onEdit: () => setState(() => _isEditing = true),
                  onCancel: () => _onCancelConfirmation(context),
                ),
        );
      },
    );
  }

}

/// View mode — shows reservation details with Edit and Cancel actions.
class _ViewMode extends StatelessWidget {
  const _ViewMode({
    required this.reservation,
    required this.isLoading,
    required this.onEdit,
    required this.onCancel,
  });

  final ReservationModel reservation;
  final bool isLoading;
  final VoidCallback onEdit;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat.yMMMd().format(reservation.scheduledAt.toLocal());
    final time = DateFormat.Hm().format(reservation.scheduledAt.toLocal());
    final guestLabel =
        reservation.people == 1 ? '1 guest' : '${reservation.people} guests';
    final isActive = reservation.status == ReservationStatus.active;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                reservation.restaurantName ?? 'Restaurant',
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ReservationStatusBadge(status: reservation.status),
          ],
        ),
        const SizedBox(height: 16),
        _DetailRow(icon: Icons.calendar_today, label: date),
        const SizedBox(height: 8),
        _DetailRow(icon: Icons.access_time, label: time),
        const SizedBox(height: 8),
        _DetailRow(icon: Icons.person, label: guestLabel),
        if (isActive) ...[
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isLoading ? null : onEdit,
                  child: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                  onPressed: isLoading ? null : onCancel,
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Edit mode — pre-filled form for updating scheduledAt and people.
class _EditForm extends StatelessWidget {
  const _EditForm({
    required this.formKey,
    required this.reservation,
    required this.isLoading,
    required this.onSave,
    required this.onDiscard,
  });

  final GlobalKey<FormBuilderState> formKey;
  final ReservationModel reservation;
  final bool isLoading;
  final VoidCallback onSave;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Edit Reservation',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          FormBuilderDateTimePicker(
            name: 'date',
            inputType: InputType.date,
            initialValue: reservation.scheduledAt.toLocal(),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 62)),
            decoration: const InputDecoration(
              labelText: 'Date',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_today),
            ),
            validator: (value) => value == null ? 'Select a date' : null,
          ),
          const SizedBox(height: 16),
          FormBuilderDateTimePicker(
            name: 'time',
            inputType: InputType.time,
            // initialValue seeds both date and time pickers from scheduledAt;
            // each picker uses only its relevant part (date or hour/minute).
            initialValue: reservation.scheduledAt.toLocal(),
            decoration: const InputDecoration(
              labelText: 'Time',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.access_time),
            ),
            validator: (value) => value == null ? 'Select a time' : null,
          ),
          const SizedBox(height: 16),
          AppTextField(
            name: 'people',
            label: 'Number of guests',
            initialValue: reservation.people.toString(),
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            validator: validatePersons,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isLoading ? null : onDiscard,
                  child: const Text('Discard'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: isLoading ? null : onSave,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save changes'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A labelled row with a leading icon — used in the detail view.
class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
