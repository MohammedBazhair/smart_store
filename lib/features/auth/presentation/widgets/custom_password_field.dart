import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomPasswordField extends StatefulWidget {
  const CustomPasswordField({
    super.key,
    required this.controller,
    required this.hintText,
    this.textInputAction = TextInputAction.next,
    this.onSubmit,
    this.originalController,
  });
  final TextEditingController controller;
  final TextEditingController? originalController;
  final String hintText;
  final VoidCallback? onSubmit;
  final TextInputAction textInputAction;

  @override
  State<CustomPasswordField> createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  bool obscure = true;

  String? get confirmPassword => widget.originalController?.text;
  bool get isConfirmField => widget.originalController != null;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      autofillHints: const [AutofillHints.password],
      obscureText: obscure,
      cursorRadius: const Radius.circular(20),
      cursorWidth: 1.3,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: (value) {
        FocusScope.of(context).nextFocus();
        widget.onSubmit?.call();
      },
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          RegExp(r'[a-zA-Z0-9!@#\$%^&*()_\-+=.?]'),
        ),
      ],
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Padding(
          padding: EdgeInsetsDirectional.only(start: 15.0),
          child: Icon(Icons.lock_outline),
        ),
        suffixIcon: IconButton(
          highlightColor: Colors.transparent,
          padding: const EdgeInsetsDirectional.only(end: 15.0),

          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => obscure = !obscure),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Password is required';
        }

        if (value.length < 8) {
          return 'Password must be at least 8 characters';
        }

        if (confirmPassword != null && value != confirmPassword) {
          return 'Passwords do not match';
        }

        return null;
      },
    );
  }
}
