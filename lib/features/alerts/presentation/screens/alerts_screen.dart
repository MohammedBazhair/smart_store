import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/presentation/widgets/common/error_widget.dart';
import '../../../../shared/presentation/widgets/common/loading_widget.dart';
import '../controllers/alert_provider.dart';
import '../widgets/alert_card.dart';
import '../widgets/alerts_app_bar.dart';
import '../widgets/alerts_empty_state.dart';

/// شاشة التنبيهات
class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(alertsProvider);

    return Scaffold(
      appBar: const AlertsAppBar(),
      body: alertsAsync.when(
        data: (alerts) {
          if (alerts.isEmpty) return const AlertsEmptyState();

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(alertsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                return AlertCard(alert: alerts[index]);
              },
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (error, _) => ErrorDisplayWidget(
          message: error.toString(),
          onRetry: () {
            ref.invalidate(alertsProvider);
          },
        ),
      ),
    );
  }
}
