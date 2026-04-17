import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_initializer.dart';
import '../../errors/result.dart';
import '../../features/alerts/data/models/alert_background_params.dart';
import '../../features/alerts/data/models/alert_model.dart';
import '../../features/alerts/presentation/controllers/alert_provider.dart';
import '../../features/products/domain/entities/store_product.dart';
import '../../features/products/presentation/controllers/product_provider.dart';
import '../../features/settings/presentation/controllers/settings_provider.dart';
import '../../features/store/presentation/controller/store_provider.dart';
import '../constants/log.dart';
import '../shared/providers/core_providers.dart';
import '../shared/providers/repositories_provider.dart';
import 'date_utils.dart';

class BackgroundUtils {
  factory BackgroundUtils(ProviderContainer container) =>
      _instance ??= BackgroundUtils._(container);
  BackgroundUtils._(this.container);

  static BackgroundUtils? _instance;

  final ProviderContainer container;

  Future<Result<int>> addAlertInBackground(
    AlertBackgroundParams params,
  ) async {
    final product = params.product;
    final repository = container.read(alertRepositoryProvider);
    final alert = AlertModel(
      productId: product.globalProduct.id!,
      daysBeforeExpiry: params.daysBeforeExpire,
      importance: Priority.high,
      isRead: false,
      createdAt: DateTime.now(),
      expiryDate: product.expiryDate,
      productName: product.globalProduct.name,
    );
    final result = await repository.addAlert(alert);

    // When the app is terminated, this Workmanager task is what fires at the due time. We must show a local notification here as well.
    final productId = product.globalProduct.id;
    if (productId != null) {
      await _showExpiryLocalNotification(
        product: product,
        daysBefore: params.daysBeforeExpire,
      );
    }

    return result;
  }

  Future<void> _showExpiryLocalNotification({
    required StoreProduct product,
    required int daysBefore,
  }) async {
    final service = container.read(alertServiceProvider);

    await service.initialize(false);

    await service.showNotification(product: product, daysBefore: daysBefore);
  }

  Future<void> dailyExpiryCheck() async {
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
    final container = AppProviders.container;
    final productRepo = container.read(productRepositoryProvider);
    final storesRepo = container.read(storeRepositoryProvider);
    final userRepo = container.read(userRepositoryProvider);
    final settingsRepo = container.read(settingsRepositoryProvider);

    try {
      // 1. لازم يكون هذا أول شيء (أساسي لكل النظام)
      final profile = await userRepo.syncAllProfiles();

      // 2. بيانات أساسية
      await Future.wait([
        settingsRepo.getExchangeRates(),
        productRepo.syncAllCategories(),
      ]);

      // 3. stores تعتمد على profile → لازم بعده مباشرة
      await storesRepo.syncAll(profile.phone!);

      // 4. باقي البيانات بالتوازي بعد ضمان الأساسيات
      await Future.wait([
        productRepo.syncAllProducts(),
        dailyExpiryCheck(),
      ]);
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      rethrow;
    }
  }
}
