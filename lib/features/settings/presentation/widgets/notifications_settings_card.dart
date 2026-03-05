import 'package:flutter/material.dart';
import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../domain/entities/settings.dart';

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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إعدادات التنبيهات',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            
            SwitchListTile(
              value: settings.enableNotifications,
              
              title: const Text('تفعيل الإشعارات'),
              secondary:
                  NotificationIcon(isEnabled: settings.enableNotifications),
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

class NotificationIcon extends StatelessWidget {
  const NotificationIcon({super.key, required this.isEnabled});
  final bool isEnabled;
  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      crossFadeState:
          isEnabled ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      firstChild: const Icon(
        Icons.notifications_active,
        color: AppTheme.primaryColor,
      ),
      secondChild: const Icon(
        Icons.notifications_none,
      ),
      duration: const Duration(milliseconds: 300),
      firstCurve: Curves.fastEaseInToSlowEaseOut,
      secondCurve: Curves.fastOutSlowIn,
    );
  }
}
