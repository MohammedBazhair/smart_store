import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../../../core/constants/enums.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../../core/utils/permissions.dart';
import '../../../../errors/result.dart';
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
              'التنبيهات',
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
            if (settings.enableNotifications &&
                !kIsWeb &&
                Platform.isAndroid) ...[
              const Divider(height: 32),
              const _AndroidBatteryOptimizationSection(),
            ],
          ],
        ),
      ),
    );
  }
}

class _AndroidBatteryOptimizationSection extends StatefulWidget {
  const _AndroidBatteryOptimizationSection();

  @override
  State<_AndroidBatteryOptimizationSection> createState() =>
      _AndroidBatteryOptimizationSectionState();
}

class _AndroidBatteryOptimizationSectionState
    extends State<_AndroidBatteryOptimizationSection>
    with WidgetsBindingObserver {
  bool _loading = true;
  bool _ignored = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refresh();
    }
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    final ignored = await PermissionsService.isIgnoringBatteryOptimizations();
    if (!mounted) return;
    setState(() {
      _ignored = ignored;
      _loading = false;
    });
  }

  Future<void> _onRequest() async {
    final result = await PermissionsService.requestIgnoreBatteryOptimizations();
    if (!mounted) return;

    if (result is ErrorState<bool>) {
      context.showSnakbar(result.message, type: SnackBarType.error);
      await _refresh();
      return;
    }

    await _refresh();
    if (!mounted) return;

    final granted = result is SuccessState<bool> ? result.data : false;
    context.showSnakbar(
      granted
          ? 'تم السماح بالتشغيل الموثوق في الخلفية'
          : 'يمكنك المحاولة لاحقًا أو فتح إعدادات البطارية أدناه',
      type: granted ? SnackBarType.success : SnackBarType.error,
    );
  }

  Future<void> _onOpenSettings() async {
    await PermissionsService.openBatteryOptimizationSettings();
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'التشغيل في الخلفية',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'لضمان وصول تنبيهات الصلاحية في الوقت، يُفضّل استثناء التطبيق من «تحسين البطارية».',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 16),
        if (_loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else ...[
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              _ignored ? Icons.battery_charging_full : Icons.battery_saver,
              color: _ignored
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            title: Text(
              _ignored ? 'التطبيق مستثنى من تحسين البطارية' : 'قيود البطارية مفعّلة',
            ),
            subtitle: Text(
              _ignored
                  ? 'يمكن للتنبيهات العمل بموثوقية أكبر في الخلفية'
                  : 'اضغط للسماح أو افتح الإعدادات يدويًا',
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: _ignored ? null : _onRequest,
                  child: const Text('السماح بالتشغيل الموثوق'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _onOpenSettings,
            child: const Text('فتح إعدادات البطارية / التطبيق'),
          ),
        ],
      ],
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
