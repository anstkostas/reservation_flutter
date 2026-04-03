import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

/// A styled [FormBuilderTextField] wrapper used across all app forms.
///
/// Provides consistent decoration (outlined border, label, hint) and optional
/// password visibility toggling. The [name] parameter is the [FormBuilder]
/// field key — use it to retrieve the value via `_formKey.currentState!.value`.
///
/// Pass validator functions directly from `lib/utils/validators.dart`.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.name,
    required this.label,
    this.hint,
    this.initialValue,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
  });

  final String name;
  final String label;
  final String? hint;
  final String? initialValue;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    // Start obscured if this is a password field; plain text otherwise.
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      name: widget.name,
      initialValue: widget.initialValue,
      obscureText: _obscure,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        border: const OutlineInputBorder(),
        // Only password fields get the toggle — avoids a pointless icon on plain text fields.
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
      ),
    );
  }
}
