import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/alerts/data/alert_repository_impl.dart';
import '../../features/alerts/domain/alert_repository.dart';
import '../../features/backup/data/backup_repository_impl.dart';
import '../../features/backup/domain/backup_repository.dart';
import '../../features/products/data/product_repository_impl.dart';
import '../../features/products/domain/product_repository.dart';
import '../../features/settings/data/settings_repository_impl.dart';
import '../../features/settings/domain/settings_repository.dart';

/// Provider لمستودع المنتجات
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl();
});


/// Provider لمستودع التنبيهات
final alertRepositoryProvider = Provider<AlertRepository>((ref) {
  return AlertRepositoryImpl();
});

/// Provider لمستودع الإعدادات
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl();
});

/// Provider لمستودع النسخ الاحتياطي
final backupRepositoryProvider = Provider<BackupRepository>((ref) {
  return BackupRepositoryImpl();
});
