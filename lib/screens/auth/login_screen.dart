import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:go_router/go_router.dart';

import '../../cubits/auth/auth_bloc.dart';
import '../../utils/validators.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/loading_indicator.dart';

/// Login screen — email + password form backed by [AuthBloc].
///
/// Navigation on success is handled by [GoRouterRefreshStream] in the router —
/// any [AuthAuthenticated] emission automatically re-evaluates the auth guard
/// and redirects to the user's home. No manual navigation needed here.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  void _onSubmit() {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;
    final values = _formKey.currentState!.value;
    context.read<AuthBloc>().add(
      AuthLoginRequested(
        email: (values['email'] as String).trim(),
        password: values['password'] as String,
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
                    'Welcome back',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to your account',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
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
                  FilledButton(
                    onPressed: _onSubmit,
                    child: const Text('Sign in'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () => context.go('/signup'),
                        child: const Text('Sign up'),
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
}
