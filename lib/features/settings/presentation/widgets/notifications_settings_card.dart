import 'package:flutter/material.dart';
import '../../domain/settings.dart';

class NotificationsSettingsCard extends StatelessWidget {
  const NotificationsSettingsCard({
    super.key,
    required this.settings,
    required this.onChanged,
  });
  final Settings settings;
  final ValueChanged<Settings> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إعدادات التنبيهات',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('تفعيل التنبيهات'),
              value: settings.enableNotifications,
              onChanged: (value) {
                onChanged(settings.copyWith(enableNotifications: value));
              },
            ),
          ],
        ),
      ),
    );
  }
}
