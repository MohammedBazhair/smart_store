import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../features/alerts/data/repositories/alert_repository_impl.dart';
import '../../../features/alerts/domain/repositories/alert_repository.dart';
import '../../../features/backup/data/backup_repository_impl.dart';
import '../../../features/backup/domain/backup_repository.dart';
import 'core_providers.dart';

// مزود SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(); // سيتم التهيئة في main
});





/// Provider لمستودع التنبيهات
final alertRepositoryProvider = Provider<AlertRepository>((ref) {
  final db = ref.read(localDatabaseServiceProvider);
  return AlertRepositoryImpl(db);
});


/// Provider لمستودع النسخ الاحتياطي
final backupRepositoryProvider = Provider<BackupRepository>((ref) {
  return BackupRepositoryImpl();
});
