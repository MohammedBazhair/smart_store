import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../features/alerts/data/alert_background_params.dart';
import '../../features/alerts/data/alert_repository_impl.dart';
import '../../features/alerts/domain/alert.dart';
import '../../features/alerts/presentation/controllers/alert_controller.dart';
import '../../features/alerts/presentation/controllers/alert_service.dart';
import '../../features/alerts/presentation/controllers/notification_service.dart';
import '../../features/products/data/product_repository_impl.dart';
import '../../features/products/domain/product.dart';
import '../../features/settings/data/settings_repository_impl.dart';
import 'date_utils.dart';
import 'result.dart';

class BackgroundUtils {
  factory BackgroundUtils() => _instance ??= BackgroundUtils._();
  BackgroundUtils._();

  static BackgroundUtils? _instance;



  
Future<Result<int>> addAlertInBackground(AlertBackgroundParams params) {
    final product = params.product;
    final repository = AlertRepositoryImpl();
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

  Future<void> dailyExpiryCheck() async {
    final repository = ProductRepositoryImpl();

    final result = await repository.getAllProducts();

    if (result is! SuccessState<List<Product>>) return;
    final settingsRepo = SettingsRepositoryImpl();
    final alertController = AlertController();
    final notifications = NotificationService.instance;

    final alertService =
        AlertService(settingsRepo, alertController, notifications);

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
