import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/shared/presentation/theme/app_theme.dart';

class CustomStoreNameField extends StatelessWidget {
  const CustomStoreNameField({
    super.key,
    required this.controller,
    this.onSubmitted,
    this.errorText,
  });

  final TextEditingController controller;
  final VoidCallback? onSubmitted;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.done,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          RegExp(r'[a-zA-Z\u0621-\u063A\u0641-\u064A\s]'),
        ),
      ],
      decoration: InputDecoration(
        hintText: 'اكتب اسم متجرك هنا...',
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        labelText: 'اسم المتجر',
        prefixIcon: const Icon(
          Icons.store,
          color: AppTheme.primaryColor,
        ),
        errorText: errorText,
        errorMaxLines: 2,
      ),
      onFieldSubmitted: (_) => onSubmitted?.call(),
      validator: (value) {
        final name = value?.trim() ?? '';

        if (name.isEmpty) {
          return 'يجب إدخال اسم متجر صحيح وغير فارغ';
        }

        if (name.length < 3) {
          return 'اسم المتجر قصير جداً';
        }

        return null;
      },
    );
  }
}
