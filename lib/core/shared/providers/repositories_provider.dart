import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../features/alerts/data/alert_repository_impl.dart';
import '../../../features/alerts/domain/alert_repository.dart';
import '../../../features/backup/data/backup_repository_impl.dart';
import '../../../features/backup/domain/backup_repository.dart';
import '../../../features/products/data/repositories/product_repository_impl.dart';
import '../../../features/products/domain/repositories/product_repository.dart';
import '../../../features/settings/data/settings_repository_impl.dart';
import '../../../features/settings/domain/settings_repository.dart';
import 'core_providers.dart';

// مزود SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(); // سيتم التهيئة في main
});

/// Provider لمستودع المنتجات
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final _remote =ref.read(remoteDatabaseServiceProvider);
  final _local = ref.read(localDatabaseServiceProvider);
final _network = ref.read(networkProvider);
  return ProductRepositoryImpl( _local, _remote, _network);
});

/// Provider لمستودع التنبيهات
final alertRepositoryProvider = Provider<AlertRepository>((ref) {
  return AlertRepositoryImpl();
});

/// Provider لمستودع الإعدادات
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);

  return SettingsRepositoryImpl(prefs);
});

/// Provider لمستودع النسخ الاحتياطي
final backupRepositoryProvider = Provider<BackupRepository>((ref) {
  return BackupRepositoryImpl();
});
