import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/handle_auth_listeners.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../settings/presentation/widgets/account_info_card.dart';
import '../../../settings/presentation/widgets/settings_app_bar.dart';

class AdminProfileScreen extends ConsumerWidget {
  const AdminProfileScreen({super.key});

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

    return Scaffold(
      appBar: const SettingsAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          AccountInfoCard(),
        ],
      ),
    );
  }
}
