import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomEmailField extends StatelessWidget {
  const CustomEmailField(this.controller, {super.key});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      autofillHints: const [AutofillHints.email],
      keyboardType: TextInputType.emailAddress,
      cursorRadius: const Radius.circular(20),
      cursorWidth: 1.3,
      textInputAction: TextInputAction.next,

      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._-]')),
      ],
      decoration: const InputDecoration(
        hintText: 'أدخل بريدك الإلكتروني',
        prefixIcon: Padding(
          padding: EdgeInsetsDirectional.only(start: 15.0),
          child: Icon(Icons.email_outlined),
        ),
      ),

    validator: (value) {
        if (value == null || value.isEmpty) {
          return 'البريد الإلكتروني مطلوب';
        }

        // Regular Email Pattern
        final emailRegExp = RegExp(
          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
        );

        if (!emailRegExp.hasMatch(value)) {
          return 'أدخل عنوان بريد إلكتروني صحيح';
        }

        return null;

    },
    );
  }
}
