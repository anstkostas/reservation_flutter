import 'package:flutter/material.dart';

/// Shown during [AuthInitial] state while the app restores the session from cookie.
/// Prevents a flash of the login screen for already-authenticated users.
/// Finalized in Phase 12 with app background color and branding.
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
