import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../errors/result.dart';
import '../../features/alerts/data/alert_background_params.dart';
import '../../features/alerts/domain/alert.dart';
import '../../features/alerts/presentation/controllers/alert_provider.dart';
import '../../features/products/presentation/controllers/product_provider.dart';
import '../../features/settings/presentation/controllers/settings_provider.dart';
import '../../features/store/presentation/controller/store_provider.dart';
import '../constants/app_constants.dart';
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
  ) {
    final product = params.product;
    final repository = container.read(alertRepositoryProvider);
    final alert = Alert(
      productId: product.globalProduct.id!,
      daysBeforeExpiry: params.daysBeforeExpire,
      importance: Priority.high,
      isRead: false,
      createdAt: DateTime.now(),
      expiryDate: product.expiryDate,
      productName: product.globalProduct.name,
    );
    return repository.addAlert(alert);
  }

  Future<void> dailyExpiryCheck() async {
    final repository = container.read(productRepositoryProvider);
    final cache = container.read(localCacheServiceProvider);
    final storeId = cache.getString(key: 'selected_store_id');
    if (storeId == null) return;

    final products = await repository.getNearExpiryProducts(storeId, 30);

    if (products.isEmpty) return;

    final alertService = container.read(alertServiceProvider);

    final futures = products.map((p) {
      if (p.expiryDate == null) return Future.value();
      final daysLeft = DateTimeUtils.daysUntilExpiry(p.expiryDate)!;

      if (daysLeft > 30) return Future.value();

      return alertService.scheduleProductAlerts(p);
    });

    await Future.wait(futures);
  }

  Future<void> syncAllData([ProviderContainer? c]) async {
    final container = c ?? this.container;
    final productRepo = container.read(productRepositoryProvider);
    final storesRepo = container.read(storeRepositoryProvider);
    final userRepo = container.read(userRepositoryProvider);
    final settingsRepo = container.read(settingsRepositoryProvider);
    final cache = container.read(localCacheServiceProvider);

    await settingsRepo.getExchangeRates();
    final profile = await userRepo.syncAllProfiles();

    final storeId = cache.getString(key: AppConstants.lastStoreIdKey);

    await storesRepo.syncAll(profile.phone!);
    await productRepo.syncAllProducts(storeId);
  }
}
