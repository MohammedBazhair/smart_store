// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/presentation/widgets/common/error_widget.dart';
import '../../../../shared/presentation/widgets/common/loading_widget.dart';
import '../../domain/settings.dart';
import '../controllers/settings_controller.dart';
import '../controllers/settings_provider.dart';
import '../widgets/backup_settings_card.dart';
import '../widgets/currency_settings_card.dart';
import '../widgets/notifications_settings_card.dart';
import '../widgets/settings_app_bar.dart';

final isLoadingProvider = StateProvider.autoDispose((ref) => false);

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _exchangeRateController = TextEditingController();

  @override
  void dispose() {
    _exchangeRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: const SettingsAppBar(),
      body: settingsAsync.when(
        data: (settings) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CurrencySettingsCard(
              settings: settings,
              exchangeRateController: _exchangeRateController,
            ),
            const SizedBox(height: 16),
            NotificationsSettingsCard(
              settings: settings,
              onChanged: _updateSettings,
            ),
            const SizedBox(height: 16),
            const BackupSettingsCard(),
          ],
        ),
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorDisplayWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(appSettingsProvider),
        ),
      ),
    );
  }

  Future<void> _updateSettings(Settings settings) async {
    final controller = ref.read(settingsControllerProvider.notifier);
    final result = await controller.updateSettings(settings);

    if (!context.mounted) return;

    if (result is SuccessState<void>) {
      context.showSnakbar('تم تحديث الإعدادات', Durations.medium4);
    } else if (result is ErrorState<void>) {
      context.showSnakbar(result.message);
    }
  }
}
