import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    context.read<OwnerRestaurantCubit>().fetch();
  }

  void _submit() {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;
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
        listenWhen: (_, current) => current is OwnerRestaurantUpdateSuccess,
        listener: (context, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.restaurantEditSuccessSnackbar)),
          );
          context.pop();
        },
        buildWhen: (_, current) => current is! OwnerRestaurantUpdateSuccess,
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
                    FormBuilderValidators.minLength(1),
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
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'descriptionEl',
                  initialValue: restaurant.description.el,
                  decoration: InputDecoration(
                    labelText: l10n.restaurantEditDescriptionElLabel,
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'address',
                  initialValue: restaurant.address,
                  decoration: InputDecoration(
                    labelText: l10n.restaurantEditAddressLabel,
                  ),
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'phone',
                  initialValue: restaurant.phone,
                  decoration: InputDecoration(
                    labelText: l10n.restaurantEditPhoneLabel,
                  ),
                  keyboardType: TextInputType.phone,
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
                    onPressed: _submit,
                    child: Text(l10n.restaurantEditSaveButton),
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
