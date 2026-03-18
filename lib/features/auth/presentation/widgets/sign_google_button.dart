import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/presentation/widgets/common/loading_widget.dart';
import '../../../audio/presentation/controller/audio_provider.dart';
import '../controllers/auth_controller.dart';
import '../controllers/auth_state.dart';

class SignGoogleButton extends ConsumerWidget {
  const SignGoogleButton({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final isLoading =
        ref.watch(authControllerProvider) is AuthGoogleLoadingState;
    return AbsorbPointer(
      absorbing: isLoading,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          side: const BorderSide(
            width: 0.3,
            color: Color.fromARGB(255, 112, 112, 112),
          ),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF172F55),
          shadowColor: const Color.fromARGB(35, 141, 141, 141),
          elevation: 1,
        ),
        onPressed: () async {
              await ref.read(audioControllerProvider.notifier).playButtonClick();

          await ref.read(authControllerProvider.notifier).loginWithGoogle();
        },
        label: isLoading
            ? const LoadingWidget()
            : const Text(
                'المتابعة عبر Google',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
        icon: isLoading
            ? const SizedBox.shrink()
            : Image.asset('assets/icons/google.png', width: 24),
      ),
    );
  }
}
