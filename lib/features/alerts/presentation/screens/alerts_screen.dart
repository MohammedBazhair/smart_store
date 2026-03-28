import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/alert.dart';
import '../controllers/alert_provider.dart';
import '../widgets/alert_card.dart';
import '../widgets/alerts_empty_state.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key, this.title, required this.alerts});
  final String? title;
  final List<Alert> alerts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: title != null ? Text(title!) : const Text('التنبيهات'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(alertControllerProvider.notifier).loadAlerts();
        },
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              child: alerts.isEmpty
                  ? const AlertsEmptyState()
                  : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: alerts.length,
                    itemBuilder: (context, index) {
                      return AlertCard(
                        alert: alerts[index],
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
