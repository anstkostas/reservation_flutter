import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:go_router/go_router.dart';

import '../../constants/user_role.dart';
import '../../cubits/auth/auth_bloc.dart';
import '../../l10n/app_localizations.dart';
import '../../cubits/restaurants/unowned_restaurant_cubit.dart';
import '../../utils/validators.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/loading_indicator.dart';

/// Signup screen — new account registration backed by [AuthBloc].
///
/// Role is derived server-side from whether [restaurantId] is provided —
/// customer accounts send null, owner accounts must claim an unowned restaurant.
///
/// [UnownedRestaurantCubit] is scoped to this route in the router and fetched
/// lazily when the user selects the owner role.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  UserRole _selectedRole = UserRole.customer;
  String? _selectedRestaurantId;

  void _onRoleChanged(Set<UserRole> selected) {
    final role = selected.first;
    setState(() {
      _selectedRole = role;
      _selectedRestaurantId = null; // clear previous selection on role switch
    });
    if (role == UserRole.owner) {
      // Fetch lazily — only triggered when the user actually picks the owner role.
      context.read<UnownedRestaurantCubit>().fetchUnowned();
    }
  }

  void _onSubmit() {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;
    final values = _formKey.currentState!.value;
    context.read<AuthBloc>().add(
      AuthSignupRequested(
        firstname: (values['firstname'] as String).trim(),
        lastname: (values['lastname'] as String).trim(),
        email: (values['email'] as String).trim(),
        password: values['password'] as String,
        // Role is derived server-side — providing restaurantId signals owner signup.
        restaurantId:
            _selectedRole == UserRole.owner ? _selectedRestaurantId : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          // AuthAuthenticated triggers GoRouterRefreshStream — the router
          // redirect fires automatically, no manual navigation needed.
        },
        builder: (context, state) {
          if (state is AuthLoading) return const LoadingIndicator();
          return _buildForm();
        },
      ),
    );
  }

  Widget _buildForm() {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: FormBuilder(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.signupTitle,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.signupSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  AppTextField(
                    name: 'firstname',
                    label: l10n.signupFirstNameLabel,
                    textInputAction: TextInputAction.next,
                    validator: requiredFieldValidator(
                      requiredMessage: l10n.validatorFieldRequired(l10n.signupFirstNameLabel),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    name: 'lastname',
                    label: l10n.signupLastNameLabel,
                    textInputAction: TextInputAction.next,
                    validator: requiredFieldValidator(
                      requiredMessage: l10n.validatorFieldRequired(l10n.signupLastNameLabel),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    name: 'email',
                    label: l10n.signupEmailLabel,
                    hint: l10n.signupEmailHint,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: emailValidator(
                      requiredMessage: l10n.validatorEmailRequired,
                      invalidMessage: l10n.validatorEmailInvalid,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    name: 'password',
                    label: l10n.signupPasswordLabel,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    validator: passwordValidator(
                      requiredMessage: l10n.validatorPasswordRequired,
                      tooShortMessage: l10n.validatorPasswordTooShort,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.signupRolePrompt,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<UserRole>(
                    segments: [
                      ButtonSegment(
                        value: UserRole.customer,
                        label: Text(l10n.signupRoleCustomer),
                        icon: const Icon(Icons.person),
                      ),
                      ButtonSegment(
                        value: UserRole.owner,
                        label: Text(l10n.signupRoleOwner),
                        icon: const Icon(Icons.storefront),
                      ),
                    ],
                    selected: {_selectedRole},
                    onSelectionChanged: _onRoleChanged,
                  ),
                  if (_selectedRole == UserRole.owner) ...[
                    const SizedBox(height: 16),
                    _buildRestaurantPicker(),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _onSubmit,
                    child: Text(l10n.signupSubmitButton),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l10n.signupHaveAccount),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: Text(l10n.signupSignInLink),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Renders the restaurant picker driven by [UnownedRestaurantCubit].
  ///
  /// Shows a loading spinner while fetching, an error with retry on failure,
  /// and a [DropdownButtonFormField] once the list is loaded.
  Widget _buildRestaurantPicker() {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<UnownedRestaurantCubit, UnownedRestaurantState>(
      builder: (context, state) {
        return switch (state) {
          UnownedInitial() || UnownedLoading() => const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(child: CircularProgressIndicator()),
            ),
          UnownedFailure(:final message) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      context.read<UnownedRestaurantCubit>().fetchUnowned(),
                  child: Text(l10n.signupRetry),
                ),
              ],
            ),
          UnownedLoaded(:final restaurants) when restaurants.isEmpty =>
            Text(
              l10n.signupNoRestaurantsAvailable,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          UnownedLoaded(:final restaurants) => DropdownButtonFormField<String>(
              initialValue: _selectedRestaurantId,
              decoration: InputDecoration(
                labelText: l10n.signupRestaurantPickerLabel,
                border: const OutlineInputBorder(),
              ),
              items: restaurants
                  .map(
                    (r) => DropdownMenuItem(value: r.id, child: Text(r.name)),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => _selectedRestaurantId = value),
              validator: (value) =>
                  value == null ? l10n.signupRestaurantPickerRequired : null,
            ),
        };
      },
    );
  }
}
