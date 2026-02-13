// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:shared_preferences/shared_preferences.dart';

import '../../../errors/result.dart';
import '../domain/settings.dart';
import '../domain/settings_repository.dart';
import 'settings_model.dart';

/// تنفيذ مستودع الإعدادات
class SettingsRepositoryImpl implements SettingsRepository {
  final SharedPreferences _prefs;
  SettingsRepositoryImpl(
    this._prefs,
  );
  final _settingsKey = 'app_settings';

  @override
  Future<Settings> getSettings() async {
    try {
      final raw = _prefs.get(_settingsKey) as String?;

      if (raw == null) {
        throw Exception('No settings found');
      }

      return SettingsModel.fromJson(raw);
    } catch (e) {
      return Settings.theDefault();
    }
  }

  @override
  Future<Result<void>> updateSettings(Settings settings) async {
    try {
      final model = SettingsModel.fromEntity(settings);

      await _prefs.setString(_settingsKey, model.toJson());

      return const SuccessState(null);
    } catch (e) {
      return const ErrorState('فشل في تحديث الإعدادات: ');
    }
  }
}
