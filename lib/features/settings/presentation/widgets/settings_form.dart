import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/enums.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../errors/result.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/settings.dart';
import '../controllers/settings_provider.dart';
import 'backup_settings_card.dart';
import 'change_phone_card.dart';
import 'change_store_selection.dart';
import 'currency_settings_card.dart';
import 'notifications_settings_card.dart';

class SettingsForm extends ConsumerStatefulWidget {
  const SettingsForm({
    super.key,
    required this.settings,
    this.isShimmerLoading = false,
  });
  final Settings settings;
  final bool isShimmerLoading;

  @override
  ConsumerState<SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends ConsumerState<SettingsForm> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CurrencySettingsCard(settings: widget.settings),
          const SizedBox(height: 16),
          NotificationsSettingsCard(
            settings: widget.settings,
            onChanged: _updateSettings,
          ),
          const SizedBox(height: 16),
          const ChangeStoreSelectionCard(),
          const SizedBox(height: 16),
          const BackupSettingsCard(),
          const SizedBox(height: 16),
          ChangePhoneCard(
            phoneController: widget.isShimmerLoading ? null : _phoneController,
          ),
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
      ),
    );
  }
}
