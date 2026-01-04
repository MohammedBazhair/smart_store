import 'package:flutter/material.dart';

import '../../domain/settings.dart';
import 'backup_settings_card.dart';
import 'currency_settings_card.dart';
import 'notifications_settings_card.dart';

class SettingsForm extends StatelessWidget {
  const SettingsForm({super.key, required this.settings, required this.onChanged, required this.exchangeRateController});
  final TextEditingController exchangeRateController;
  final Settings settings;
  final ValueChanged<Settings> onChanged;

  @override
  Widget build(BuildContext context) {
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
        const BackupSettingsCard(),
      ],
    );
  }
}
