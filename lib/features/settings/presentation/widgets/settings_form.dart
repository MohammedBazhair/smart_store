import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/settings.dart';
import 'backup_settings_card.dart';
import 'change_store_selection.dart';
import 'currency_settings_card.dart';
import 'notifications_settings_card.dart';

class SettingsForm extends ConsumerWidget {
  const SettingsForm({
    super.key,
    required this.settings,
    required this.onChanged,
    this.exchangeRateController,
  });
  final TextEditingController? exchangeRateController;
  final Settings settings;
  final ValueChanged<Settings> onChanged;

  @override
  Widget build(BuildContext context,ref) {
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        CurrencySettingsCard(
          settings: settings,
          exchangeRateController: exchangeRateController,
        ),
        const SizedBox(height: 16),
        NotificationsSettingsCard(
          settings: settings,
          onChanged: onChanged,
        ),
        const SizedBox(height: 16),
        const ChangeStoreSelectionCard(),
        const SizedBox(height: 16),
        const BackupSettingsCard(),
        const SizedBox(height: 16),

        Consumer(
          builder: (_, ref, __) {
            return TextButton.icon(
              icon: const Icon(Icons.exit_to_app),
              onPressed: () =>
                  ref.read(authControllerProvider.notifier).signOut(),
              label: const Text('تسجل الخروج'),
            );
          },
        ),
      ],
    );
  }
}
