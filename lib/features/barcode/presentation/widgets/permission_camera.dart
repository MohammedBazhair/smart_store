import 'package:flutter/material.dart';

class PermissionCameraWidget extends StatelessWidget {
  const PermissionCameraWidget({super.key, required this.onButtonPressed});
  final VoidCallback onButtonPressed;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'الرجاء السماح باستخدام الكاميرا',
          textAlign: TextAlign.center,
        ),
        SizedBox(
          width: 50,
          child: TextButton(
            style: TextButton.styleFrom(
              fixedSize: const Size.fromWidth(100),
            ),
            onPressed: onButtonPressed,
            child: const Text('السماح'),
          ),
        ),
      ],
    );
  }
}
