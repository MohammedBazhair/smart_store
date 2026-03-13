import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../handle_auth_listeners.dart';
import '../controllers/auth_controller.dart';

class SignOutButton extends ConsumerWidget {
  const SignOutButton({
    super.key,
    this.color,
  });

  final Color? color;

  @override
  Widget build(BuildContext context, ref) {
    ref.listen(authControllerProvider, (previous, next) {
      handlgeAuthListener(
        context: context,
        previous: previous,
        next: next,
        ref: ref,
      );
    });

    return IconButton(
      tooltip: 'تسجيل الخروج',
      onPressed: ref.read(authControllerProvider.notifier).signOut,
      icon: Icon(Icons.logout, color: color),
    );
  }
}
