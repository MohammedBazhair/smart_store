import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../../../core/constants/enums.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../../core/shared/presentation/widgets/common/loading_widget.dart';
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
            if (!kIsWeb && Platform.isAndroid)
              const _AndroidBatteryOptimizationSection(),
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
  bool _isBatteryOptimizationIgnored = false;

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
      _isBatteryOptimizationIgnored = ignored;
      _loading = false;
    });
  }

  Future<void> _enableExemption() async {
    final result =
        await PermissionsService.enableBatteryOptimizationExemption();
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
          ? 'تم تفعيل التشغيل في الخلفية'
          : 'لم يتم التغيير. يمكنك تعديل الإعداد من الإعدادات',
      type: granted ? SnackBarType.success : SnackBarType.error,
    );
  }

  Future<void> _disableExemption() async {
    final result =
        await PermissionsService.disableBatteryOptimizationExemption();
    if (!mounted) return;

    if (result is ErrorState<bool>) {
      context.showSnakbar(result.message, type: SnackBarType.error);
      await _refresh();
      return;
    }

    await _refresh();
    if (!mounted) return;

    final notGranted = result is SuccessState<bool> ? result.data : false;
    context.showSnakbar(
      notGranted
          ? 'تم إلغاء استثناء البطارية (قد تتأخر الإشعارات)'
          : 'لم يتم التغيير. يمكنك تعديل الإعداد من إعدادات النظام',
      type: notGranted ? SnackBarType.success : SnackBarType.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_loading)
          const LoadingWidget()
        else
          SwitchListTile(
            value: _isBatteryOptimizationIgnored,
            title: const Text('السماح للإشعارات بالعمل في الخلفية'),
            secondary:
                NotificationIcon(isEnabled: _isBatteryOptimizationIgnored),
            onChanged: (value) {
              value ? _enableExemption() : _disableExemption();
            },
          ),
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
