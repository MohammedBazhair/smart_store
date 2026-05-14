import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../fields_formatters/phone_number_formatter.dart';

class CustomPhoneField extends StatelessWidget {
  const CustomPhoneField(
    this.controller, {
    super.key,
    this.validator,
    this.onChanged,
    this.errorMaxLines = 1,
  });
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final int errorMaxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      autofillHints: const [AutofillHints.telephoneNumber],
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
      keyboardType: TextInputType.phone,
      cursorRadius: const Radius.circular(20),
      cursorWidth: 1.3,
      textInputAction: TextInputAction.done,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        PhoneNumberFormatter(),
      ],
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'أدخل رقم الهاتف',
        helperMaxLines: 2,
        prefixIcon: const Padding(
          padding: EdgeInsetsDirectional.only(start: 15.0),
          child: Icon(Icons.phone),
        ),
        errorMaxLines: errorMaxLines,
      ),
      validator: (value) {
        final withoutSpaces = value?.replaceAll(' ', '') ?? '';

        if (withoutSpaces.isEmpty) {
          return 'الهاتف مطلوب';
        }

        if (!withoutSpaces.startsWith('7') || withoutSpaces.length != 9) {
          return 'أدخل رقم هاتف صحيح';
        }

        return validator?.call(withoutSpaces);
      },
    );
  }
}
