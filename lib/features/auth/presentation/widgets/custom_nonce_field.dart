import 'package:flutter/material.dart';

class CustomNonceField extends StatelessWidget {
  const CustomNonceField({super.key, required this.nonceController});

  final TextEditingController nonceController;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: nonceController,
      cursorRadius: const Radius.circular(20),
      cursorWidth: 1.3,
      textInputAction: TextInputAction.next,

      decoration: const InputDecoration(
        hintText: 'أدخل الرمز المرسل',
        prefixIcon: Padding(
          padding: EdgeInsetsDirectional.only(start: 15.0),
          child: Icon(Icons.person_outline),
        ),
      ),

      

      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'رمز التأكيد مطلوب';
        }


        return null;
      },
    );
  }
}
