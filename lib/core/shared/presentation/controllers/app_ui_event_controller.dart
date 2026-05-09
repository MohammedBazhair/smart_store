import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/enums.dart';
import '../../../extensions/extensions.dart';
import '../../domain/entities/app_ui_event.dart';
import '../../providers/ui_providers.dart';

class AppUiEventController extends Notifier<AppUiEvent?> {
  @override
  AppUiEvent? build() {
    return null;
  }

  void _showMessage({
    required String message,
    required SnackBarType type,
  }) {
    state = AppUiEvent(
      message: message,
      type: type,
    );
  }

  void showSuccess(String message) {
    _showMessage(message: message, type: SnackBarType.success);
  }

  void showError(String message) {
    _showMessage(message: message, type: SnackBarType.error);
  }

  void clear() => state = null;
}

/// You Must Call it in Build Method
void listenToUiEvents(BuildContext context, WidgetRef ref) {
  ref.listen(
    appUiEventProvider,
    (_, state) {
      if (state == null) return;

      context.showSnakbar(state.message, type: state.type);
      ref.read(appUiEventProvider.notifier).clear();
    },
  );
}
