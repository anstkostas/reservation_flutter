import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';

import 'package:antigravity_client/cubits/restaurants/owner_restaurant_cubit.dart';
import 'package:antigravity_client/l10n/app_localizations.dart';
import 'package:antigravity_client/layouts/app_navbar.dart';
import 'package:antigravity_client/models/models.dart';
import 'package:antigravity_client/utils/error_resolver.dart';
import 'package:antigravity_client/widgets/error_display.dart';
import 'package:antigravity_client/widgets/loading_indicator.dart';

/// Owner-only screen for editing the authenticated owner's restaurant details.
///
/// Fetches the current restaurant on mount to pre-fill the form. On successful
/// save, shows a snackbar and pops back to the dashboard.
class RestaurantEditScreen extends StatefulWidget {
  const RestaurantEditScreen({super.key});

  @override
  State<RestaurantEditScreen> createState() => _RestaurantEditScreenState();
}

class _RestaurantEditScreenState extends State<RestaurantEditScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isSubmitting = false;

  // Maps backend field names (from ValidationError.details[].field) to form field names.
  // The backend validate middleware uses path[0], so nested description.en/.el both
  // land as "description" — mapped to the EN field as best effort.
  static const _backendToFormField = {
    'name': 'name',
    'description': 'descriptionEn',
    'address': 'address',
    'phone': 'phone',
    'capacity': 'capacity',
  };

  @override
  void initState() {
    super.initState();
    context.read<OwnerRestaurantCubit>().fetch();
  }

  void _submit() {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;
    setState(() => _isSubmitting = true);

    final values = _formKey.currentState!.value;

    final capacityRaw = values['capacity'] as String?;
    final capacity = capacityRaw != null && capacityRaw.isNotEmpty
        ? int.tryParse(capacityRaw)
        : null;

    context.read<OwnerRestaurantCubit>().update(
      UpdateRestaurantRequest(
        name: values['name'] as String?,
        descriptionEn: values['descriptionEn'] as String?,
        descriptionEl: values['descriptionEl'] as String?,
        address: values['address'] as String?,
        phone: values['phone'] as String?,
        capacity: capacity,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppNavbar(),
      body: BlocConsumer<OwnerRestaurantCubit, OwnerRestaurantState>(
        listenWhen: (_, current) =>
            current is OwnerRestaurantUpdateSuccess ||
            current is OwnerRestaurantUpdateFailure,
        listener: (context, state) {
          if (state is OwnerRestaurantUpdateSuccess) {
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.restaurantEditSuccessSnackbar)),
            );
            context.pop();
          } else if (state is OwnerRestaurantUpdateFailure) {
            setState(() => _isSubmitting = false);
            final details = state.details;
            if (details != null && details.isNotEmpty) {
              bool hasUnmapped = false;
              for (final detail in details) {
                final backendField = detail['field'] as String?;
                final message = detail['message'] as String?;
                if (backendField == null || message == null) continue;
                final formField = _backendToFormField[backendField];
                if (formField != null) {
                  _formKey.currentState?.fields[formField]?.invalidate(message);
                } else {
                  hasUnmapped = true;
                }
              }
              if (hasUnmapped) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          }
        },
        buildWhen: (_, current) =>
            current is! OwnerRestaurantUpdateSuccess &&
            current is! OwnerRestaurantUpdateFailure,
        builder: (context, state) {
          return switch (state) {
            OwnerRestaurantInitial() ||
            OwnerRestaurantLoading() => const LoadingIndicator(),
            OwnerRestaurantFailure(:final message, :final code) => ErrorDisplay(
              message: resolveErrorMessage(
                context,
                message: message,
                code: code,
              ),
              onRetry: () => context.read<OwnerRestaurantCubit>().fetch(),
            ),
            OwnerRestaurantLoaded(:final restaurant) => _buildForm(
              context,
              l10n,
              restaurant,
            ),
            // UpdateSuccess filtered by buildWhen — never reached.
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    AppLocalizations l10n,
    RestaurantPrivateModel restaurant,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.restaurantEditTitle,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.restaurantEditSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          FormBuilder(
            key: _formKey,
            child: Column(
              children: [
                FormBuilderTextField(
                  name: 'name',
                  initialValue: restaurant.name,
                  decoration: InputDecoration(
                    labelText: l10n.restaurantEditNameLabel,
                  ),
                  validator: FormBuilderValidators.compose([
                    (value) => (value == null || value.trim().isEmpty)
                        ? l10n.validatorRestaurantNameRequired
                        : null,
                    FormBuilderValidators.minLength(4,
                        errorText: l10n.validatorRestaurantNameTooShort),
                    FormBuilderValidators.maxLength(100,
                        errorText: l10n.validatorRestaurantNameTooLong),
                    (value) => (value != null &&
                            !RegExp(r'\p{L}', unicode: true).hasMatch(value))
                        ? l10n.validatorRestaurantNameNoLetter
                        : null,
                    (value) => (value != null &&
                            RegExp(r'[^\p{L}\p{N}\s]{2,}', unicode: true)
                                .hasMatch(value))
                        ? l10n.validatorRestaurantNameConsecutiveSpecial
                        : null,
                  ]),
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'descriptionEn',
                  initialValue: restaurant.description.en,
                  decoration: InputDecoration(
                    labelText: l10n.restaurantEditDescriptionEnLabel,
                  ),
                  maxLines: 4,
                  validator: FormBuilderValidators.compose([
                    (value) => (value == null || value.trim().isEmpty)
                        ? l10n.validatorRestaurantDescriptionEnRequired
                        : null,
                    FormBuilderValidators.maxLength(500),
                    (value) => (value != null &&
                            RegExp(r'[Ͱ-Ͽἀ-῿]')
                                .hasMatch(value))
                        ? l10n.validatorRestaurantDescriptionEnLatinOnly
                        : null,
                    (value) => (value != null &&
                            value.trim().isNotEmpty &&
                            !RegExp(r'\p{Script=Latin}', unicode: true)
                                .hasMatch(value))
                        ? l10n.validatorRestaurantDescriptionEnNoLetter
                        : null,
                  ]),
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'descriptionEl',
                  initialValue: restaurant.description.el,
                  decoration: InputDecoration(
                    labelText: l10n.restaurantEditDescriptionElLabel,
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;
                    if (RegExp(r'[a-zA-Z]').hasMatch(value)) {
                      return l10n.validatorRestaurantDescriptionElGreekOnly;
                    }
                    if (!RegExp(r'\p{Script=Greek}', unicode: true)
                        .hasMatch(value)) {
                      return l10n.validatorRestaurantDescriptionElNoLetter;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'address',
                  initialValue: restaurant.address,
                  decoration: InputDecoration(
                    labelText: l10n.restaurantEditAddressLabel,
                  ),
                  validator: FormBuilderValidators.compose([
                    (value) => (value == null || value.trim().isEmpty)
                        ? l10n.validatorRestaurantAddressRequired
                        : null,
                    (value) => (value != null &&
                            value.isNotEmpty &&
                            !RegExp(r'\p{L}', unicode: true).hasMatch(value))
                        ? l10n.validatorRestaurantAddressNoLetter
                        : null,
                  ]),
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'phone',
                  initialValue: restaurant.phone,
                  decoration: InputDecoration(
                    labelText: l10n.restaurantEditPhoneLabel,
                  ),
                  keyboardType: TextInputType.text,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: FormBuilderValidators.compose([
                    (value) => (value == null || value.isEmpty)
                        ? l10n.validatorRestaurantPhoneRequired
                        : null,
                    FormBuilderValidators.minLength(7,
                        errorText: l10n.validatorRestaurantPhoneTooShort),
                    FormBuilderValidators.maxLength(15,
                        errorText: l10n.validatorRestaurantPhoneTooLong),
                  ]),
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'capacity',
                  initialValue: restaurant.capacity.toString(),
                  decoration: InputDecoration(
                    labelText: l10n.restaurantEditCapacityLabel,
                  ),
                  keyboardType: TextInputType.number,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.integer(),
                    FormBuilderValidators.min(1),
                  ]),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.restaurantEditSaveButton),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
