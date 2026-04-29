import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/shared/presentation/controllers/app_ui_event_controller.dart';
import '../controllers/alert_provider.dart';
import '../widgets/alert_card.dart';
import '../widgets/alerts_empty_state.dart';
import '../widgets/clear_alerts_action.dart';

enum AlertsScreenType {
  all,
  unRead,
}

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key, required this.alertsScreenType});
  final AlertsScreenType alertsScreenType;

  bool get isAllType => alertsScreenType == AlertsScreenType.all;

  String get getTitle {
    return switch (alertsScreenType) {
      AlertsScreenType.all => 'التنبيهات',
      AlertsScreenType.unRead => 'التنبيهات الجديدة',
    };
  }

  @override
  Widget build(BuildContext context, ref) {
    listenToUiEvents(context, ref);

    final alerts = switch (alertsScreenType) {
      AlertsScreenType.all => ref.watch(
          alertsControllerProvider.select((s) => s.allAlerts.values.toList()),
        ),
      AlertsScreenType.unRead => ref.watch(
          alertsControllerProvider
              .select((s) => s.unreadAlerts.values.toList()),
        ),
    };

    final hasReadAlerts =
        ref.watch(alertsControllerProvider.select((s) => s.hasReadAlert));
    final showClearReadAlertsAction = isAllType && hasReadAlerts;

    return Scaffold(
      appBar: AppBar(
        title: Text(getTitle),
        actions: [
          if (showClearReadAlertsAction) const ClearReadAlertsAction(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(alertsControllerProvider.notifier).loadAlerts();
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
