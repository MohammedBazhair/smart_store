import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../core/shared/presentation/widgets/common/error_widget.dart';
import '../../../auth/auth_listeners.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/settings.dart';
import '../controllers/settings_provider.dart';
import '../widgets/settings_app_bar.dart';
import '../widgets/settings_form.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

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

    final settingsAsync = ref.watch(settingsControllerProvider);

    return Scaffold(
      appBar: const SettingsAppBar(),
      body: settingsAsync.when(
        data: (settings) => SettingsForm(
          settings: settings,
        ),
        loading: () => Skeletonizer(
          child: SettingsForm(
            settings: Settings.theDefault(const []),
          ),
        ),
        error: (e, _) => ErrorDisplayWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(settingsControllerProvider),
        ),
      ),
    );
  }
}
