import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../errors/result.dart';
import '../../features/alerts/data/alert_background_params.dart';
import '../../features/alerts/domain/alert.dart';
import '../../features/alerts/presentation/controllers/alert_provider.dart';
import '../../features/products/domain/product.dart';
import '../shared/providers/repositories_provider.dart';
import 'date_utils.dart';

class BackgroundUtils {
  factory BackgroundUtils() => _instance ??= BackgroundUtils._();
  BackgroundUtils._();

  static BackgroundUtils? _instance;

  Future<Result<int>> addAlertInBackground(
    ProviderContainer container,
    AlertBackgroundParams params,
  ) {
    final product = params.product;
    final repository = container.read(alertRepositoryProvider);
    final alert = Alert(
      productId: product.id!,
      daysBeforeExpiry: params.daysBeforeExpire,
      importance: Priority.high,
      isRead: false,
      createdAt: DateTime.now(),
      expiryDate: product.expiryDate,
      productName: product.name,
    );
    return repository.addAlert(alert);
  }

  Future<void> dailyExpiryCheck(ProviderContainer container) async {
    final repository = container.read(productRepositoryProvider);

    final result = await repository.getNearExpiryProducts(30);

    if (result is! SuccessState<List<Product>>) return;

    final alertService = container.read(alertServiceProvider);

    final products = result.data;

    final futures = products.map((p) {
      if (p.expiryDate == null) return Future.value();
      final daysLeft = DateTimeUtils.daysUntilExpiry(p.expiryDate)!;

      if (daysLeft > 30) return Future.value();

      return alertService.scheduleProductAlerts(p);
    });

    await Future.wait(futures);
  }
}
