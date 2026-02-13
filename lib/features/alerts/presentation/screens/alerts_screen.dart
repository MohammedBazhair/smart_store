import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/presentation/widgets/common/error_widget.dart';
import '../../../../core/shared/presentation/widgets/common/loading_widget.dart';
import '../../domain/alert.dart';
import '../widgets/alert_card.dart';
import '../widgets/alerts_empty_state.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key, this.title, required this.alertsProvider});
  final String? title;
  final FutureProvider<List<Alert>> alertsProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(alertsProvider);

    return Scaffold(
      appBar: AppBar(
        title: title != null ? Text(title!) : const Text('التنبيهات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(alertsProvider);
            },
          ),
        ],
      ),
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
                return AlertCard(
                  alert: alerts[index],
                );
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
