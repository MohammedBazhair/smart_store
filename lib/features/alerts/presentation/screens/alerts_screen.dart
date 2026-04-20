import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/alert_provider.dart';
import '../widgets/alert_card.dart';
import '../widgets/alerts_empty_state.dart';
enum AlertsScreenType {
  all,
  unRead,
}
class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key, this.title, required this.alertsScreenType});
  final String? title;
  final AlertsScreenType alertsScreenType;

  @override
  Widget build(BuildContext context,  ref) {

    final alerts = switch(alertsScreenType) {
      AlertsScreenType.all => ref.watch(alertControllerProvider.select((s)=>s.allAlerts.values.toList())),
      AlertsScreenType.unRead => ref.watch(alertControllerProvider.select((s)=>s.unreadAlerts.values.toList())),
    };

    return Scaffold(
      appBar: AppBar(
        title: title != null ? Text(title!) : const Text('التنبيهات'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(alertControllerProvider.notifier).loadAlerts();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.all(alerts.isEmpty ? 24 : 16),
              sliver: alerts.isEmpty
                  ? const SliverFillRemaining(
                      child: AlertsEmptyState(),
                    )
                  : SliverList.builder(
                      itemBuilder: (_, index) => AlertCard(
                        alert: alerts[index],
                      ),
                      itemCount: alerts.length,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
