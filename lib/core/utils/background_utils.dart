import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../app_initializer.dart';
import '../../features/alerts/data/models/alert_background_params.dart';
import '../../features/alerts/data/models/alert_model.dart';
import '../../features/alerts/domain/entities/expiry_reminder.dart';
import '../../features/alerts/presentation/controllers/alert_provider.dart';
import '../../features/products/presentation/controllers/product_provider.dart';
import '../../features/settings/presentation/controllers/settings_provider.dart';
import '../../features/store/presentation/controller/store_provider.dart';
import '../constants/log.dart';
import '../shared/providers/core_providers.dart';
import '../shared/providers/repositories_provider.dart';
import 'date_utils.dart';

class BackgroundUtils {
  factory BackgroundUtils() => _instance ??= BackgroundUtils._();
  BackgroundUtils._();

  static BackgroundUtils? _instance;

  Future<void> addAlertInBackground(
    AlertBackgroundParams params,
  ) async {
    final product = params.product;
    final container = await AppProviders.container;
    final repository = container.read(alertRepositoryProvider);
    if (product.expiryDate == null || product.id == null) {
      return;
    }

    final isAlertDuplicated = await repository.isAlertDuplicated(
      productId: product.id!,
      expiryDate: product.expiryDate!,
      daysBeforeExpiry: params.daysBeforeExpire,
    );

    if (isAlertDuplicated) return;

    final alert = AlertModel(
      productId: product.globalProduct.id!,
      expiryRemainder: ExpiryRemainder(
        daysBeforeExpiry: params.daysBeforeExpire,
        importance: Priority.high,
      ),
      isRead: false,
      createdAt: DateTime.now(),
      expiryDate: product.expiryDate!,
      productName: product.globalProduct.name,
    );
    await repository.addAlert(alert);
  }

  Future<void> dailyExpiryCheck() async {
    final container = await AppProviders.container;

    final repository = container.read(productRepositoryProvider);
    final cache = container.read(localCacheServiceProvider);
    final storeId = cache.getString(key: 'selected_store_id');
    if (storeId == null) return;

    final products = await repository.getNearExpiryProducts(storeId, 30);

    if (products.isEmpty) return;

    final alertService = container.read(alertServiceProvider);
    await alertService.initialize(false);

    final futures = products.map((p) {
      if (p.expiryDate == null) return Future.value();
      final daysLeft = DateTimeUtils.daysUntilExpiry(p.expiryDate)!;

      if (daysLeft > 30) return Future.value();

      return alertService.scheduleProductAlerts(p);
    });

    await Future.wait(futures);
  }

  Future<void> syncAllData() async {
    final container = await AppProviders.container;

    final syncRepo = container.read(syncProductRepositoryProvider);
    final storesRepo = container.read(storeRepositoryProvider);
    final userRepo = container.read(userRepositoryProvider);
    final settingsRepo = container.read(settingsRepositoryProvider);

    try {
      // 1. لازم يكون هذا أول شيء (أساسي لكل النظام)
      final profile = await userRepo.syncAllProfiles();

      // 2. بيانات أساسية
      await Future.wait([
        settingsRepo.getExchangeRates(),
        syncRepo.syncAllCategories(),
      ]);

      // 3. stores تعتمد على profile → لازم بعده مباشرة
      await storesRepo.syncAll(profile.phone!);

      // 4. باقي البيانات بالتوازي بعد ضمان الأساسيات
      await Future.wait([
        syncRepo.syncAllProducts(),
        dailyExpiryCheck(),
      ]);
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> removeOldAlerts() async {
    final container = await AppProviders.container;

    final repo = container.read(alertRepositoryProvider);
    await repo.deleteReadAlerts();
  }
}
