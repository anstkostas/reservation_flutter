import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:go_router/go_router.dart';

import '../../constants/user_role.dart';
import '../../cubits/auth/auth_bloc.dart';
import '../../cubits/restaurants/restaurant_cubit.dart';
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
                    'Create account',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fill in the details below to get started',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  AppTextField(
                    name: 'firstname',
                    label: 'First name',
                    textInputAction: TextInputAction.next,
                    validator: (v) => validateRequired(v, 'First name'),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    name: 'lastname',
                    label: 'Last name',
                    textInputAction: TextInputAction.next,
                    validator: (v) => validateRequired(v, 'Last name'),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    name: 'email',
                    label: 'Email',
                    hint: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: validateEmail,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    name: 'password',
                    label: 'Password',
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    validator: validatePassword,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'I am signing up as a:',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<UserRole>(
                    segments: const [
                      ButtonSegment(
                        value: UserRole.customer,
                        label: Text('Customer'),
                        icon: Icon(Icons.person),
                      ),
                      ButtonSegment(
                        value: UserRole.owner,
                        label: Text('Restaurant owner'),
                        icon: Icon(Icons.storefront),
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
                    child: const Text('Create account'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account?'),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text('Sign in'),
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
                  child: const Text('Retry'),
                ),
              ],
            ),
          UnownedLoaded(:final restaurants) when restaurants.isEmpty =>
            Text(
              'No restaurants available to claim. Sign up as a customer instead.',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          UnownedLoaded(:final restaurants) => DropdownButtonFormField<String>(
              initialValue: _selectedRestaurantId,
              decoration: const InputDecoration(
                labelText: 'Select your restaurant',
                border: OutlineInputBorder(),
              ),
              items: restaurants
                  .map(
                    (r) => DropdownMenuItem(value: r.id, child: Text(r.name)),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => _selectedRestaurantId = value),
              validator: (value) =>
                  value == null ? 'Select a restaurant to claim' : null,
            ),
        };
      },
    );
  }
}
