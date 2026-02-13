import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/auth_controller.dart';

class SignGoogleButton extends ConsumerWidget {
  const SignGoogleButton({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xEAFFFFFF).withOpacity(0.9),
        foregroundColor: Colors.black,
      ),
      onPressed: () async {
        await ref.read(authProvider.notifier).loginWithGoogle();
      },
      label: const Text('المتابعة عبر Google'),
      icon: Image.asset('assets/icons/google.png', width: 24),
    );
  }
}
