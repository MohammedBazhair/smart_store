import 'package:shared_preferences/shared_preferences.dart';

abstract interface class LocalCacheService {
  Future<bool> setString({required String key, required String value});

  String? getString({required String key});

  Future<bool> setBool({required String key, required bool value});

  bool? getBool({required String key});

  Future<bool> setInt({required String key, required int value});

  int? getInt({required String key});

  Future<bool> setStringList({
    required String key,
    required List<String> value,
  });

  List<String>? getStringList({required String key});

  Future<bool> remove({required String key});

  Future<bool> clear();
}

class LocalCacheServiceImpl implements LocalCacheService {
  LocalCacheServiceImpl(this._prefs);
  final SharedPreferences _prefs;

  @override
  Future<bool> setString({required String key, required String value}) {
    return _prefs.setString(key, value);
  }

  @override
String? getString({required String key})  {
    return _prefs.getString(key);
  }

  @override
  Future<bool> setBool({required String key, required bool value}) {
    return _prefs.setBool(key, value);
  }

  @override
  bool? getBool({required String key})  {
    return _prefs.getBool(key);
  }

  @override
  Future<bool> setInt({required String key, required int value}) {
    return _prefs.setInt(key, value);
  }

  @override
  int? getInt({required String key})  {
    return _prefs.getInt(key);
  }

  @override
  Future<bool> setStringList({
    required String key,
    required List<String> value,
  }) {
    return _prefs.setStringList(key, value);
  }

  @override
  List<String>? getStringList({required String key})  {
    return _prefs.getStringList(key);
  }

  @override
  Future<bool> remove({required String key}) {
    return _prefs.remove(key);
  }

  @override
  Future<bool> clear() {
    return _prefs.clear();
  }
}
