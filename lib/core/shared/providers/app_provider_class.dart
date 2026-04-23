import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../../../app_initializer.dart';
import '../../database/local/database_helper.dart';
import 'core_providers.dart';
import 'repositories_provider.dart';

class AppProviders {
  AppProviders._();
  static ProviderContainer? _container;
  

  static Future<ProviderContainer> get container async {
    if (!_hasContainer) await _initialize();
    return _container!;
  }

  static bool get _hasContainer => _container != null;

  static Future<void> _initialize() async {
    final [_, _, sharedPrefs as SharedPreferences, database as Database] =
        await Future.wait([
      initializeDateFormatting('ar'),
      initializeSupabase(),
      SharedPreferences.getInstance(),
      DatabaseHelper.instance.database,
    ]);

    _container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
        databaseProvider.overrideWithValue(database),
      ],
    );
  }
}
