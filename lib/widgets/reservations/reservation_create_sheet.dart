import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../constants/breakpoints.dart';
import '../../cubits/reservations/customer/customer_reservation_cubit.dart';
import '../../utils/validators.dart';
import '../app_text_field.dart';

/// Sheet for creating a new reservation.
///
/// Opened via [ReservationCreateSheet.show], which chooses between
/// [showModalBottomSheet] on mobile and [showDialog] on tablet/desktop.
///
/// On success the sheet closes automatically — [CustomerReservationActionSuccess]
/// triggers [Navigator.pop] in the listener, and the cubit immediately
/// re-fetches so [ReservationHistoryScreen] refreshes.
class ReservationCreateSheet extends StatefulWidget {
  const ReservationCreateSheet({super.key, required this.restaurantId});

  final String restaurantId;

  /// Opens the sheet adaptively based on screen size.
  ///
  /// [CustomerReservationCubit] is accessible via [MultiBlocProvider] at the
  /// app root, so no extra [BlocProvider.value] wrapper is needed here.
  static void show(BuildContext context, String restaurantId) {
    if (Breakpoints.isPhone(MediaQuery.sizeOf(context))) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true, // required for keyboard avoidance
        useSafeArea: true,
        builder: (_) => ReservationCreateSheet(restaurantId: restaurantId),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          child: SizedBox(
            width: 480,
            child: ReservationCreateSheet(restaurantId: restaurantId),
          ),
        ),
      );
    }
  }

  @override
  State<ReservationCreateSheet> createState() =>
      _ReservationCreateSheetState();
}

class _ReservationCreateSheetState extends State<ReservationCreateSheet> {
  final _formKey = GlobalKey<FormBuilderState>();

  void _onSubmit() {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;
    final values = _formKey.currentState!.value;

    final date = values['date'] as DateTime;
    // InputType.time stores as DateTime — only hour/minute are meaningful.
    final time = values['time'] as DateTime;
    final scheduledAt = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    final people = int.parse(values['people'] as String);

    context.read<CustomerReservationCubit>().create(
      restaurantId: widget.restaurantId,
      scheduledAt: scheduledAt,
      people: people,
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is CustomerReservationLoading;
        return Padding(
          // Push content above the keyboard on mobile.
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: 24 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Make a Reservation',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                FormBuilderDateTimePicker(
                  name: 'date',
                  inputType: InputType.date,
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
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  validator: validatePersons,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: isLoading ? null : _onSubmit,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Confirm'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
