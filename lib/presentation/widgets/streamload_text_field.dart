// lib/presentation/widgets/streamload_text_field.dart
import 'package:flutter/material.dart';

class StreamloadTextField extends StatelessWidget {
  const StreamloadTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscure = false,
    this.autofocus = false,
    this.keyboardType,
    this.onSubmitted,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscure;
  final bool autofocus;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      autofocus: autofocus,
      keyboardType: keyboardType,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      decoration: InputDecoration(
        labelText: label.toUpperCase(),
        hintText: hint,
      ),
    );
  }
}
