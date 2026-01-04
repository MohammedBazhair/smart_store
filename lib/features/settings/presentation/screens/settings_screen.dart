import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/constants/enums.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/presentation/widgets/common/error_widget.dart';
import '../../domain/settings.dart';
import '../controllers/settings_controller.dart';
import '../controllers/settings_provider.dart';
import '../widgets/settings_app_bar.dart';
import '../widgets/settings_form.dart';

final isLoadingProvider =
    StateProvider.family<bool, IsLoading>((ref, type) => false);

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
        data: (settings) => SettingsForm(
            settings: settings,
            onChanged: _updateSettings,
            exchangeRateController: _exchangeRateController,
          ),
        loading: () => Skeletonizer(
            child: SettingsForm(
              settings: Settings.fake(),
              onChanged: (_) {},
              exchangeRateController: _exchangeRateController,
            ),
          ),
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
      context.showSnakbar('تم تحديث الإعدادات', type: SnackBarType.success);
    } else if (result is ErrorState<void>) {
      context.showSnakbar(result.message, type: SnackBarType.error);
    }
  }
}
