import 'package:flutter/material.dart';

/// Shown during [AuthInitial] while the app restores the session from cookie.
/// Prevents a flash of the login screen for already-authenticated users.
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}
