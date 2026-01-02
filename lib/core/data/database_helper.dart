import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../constants/app_constants.dart';

/// مساعد قاعدة البيانات
class DatabaseHelper {
  DatabaseHelper._init();
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  /// الحصول على قاعدة البيانات
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.databaseName);
    return _database!;
  }

  /// تهيئة قاعدة البيانات
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _createDB,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        quantity INTEGER,
        barcode TEXT UNIQUE ,
        expiry_date TEXT NOT NULL,
        category TEXT NOT NULL,
        price REAL NOT NULL,
        currency TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

  

    await db.execute('''
      CREATE TABLE alerts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        expiry_date TEXT NOT NULL,
        days_before_expiry INTEGER NOT NULL,
        importance TEXT NOT NULL,
        is_read INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        id TEXT PRIMARY KEY,
        default_currency TEXT NOT NULL,
        exchange_rate REAL NOT NULL,
        alert_days_30 INTEGER NOT NULL,
        alert_days_7 INTEGER NOT NULL,
        alert_days_1 INTEGER NOT NULL,
        enable_notifications INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // إدراج الإعدادات الافتراضية
    await db.insert('settings', {
      'id': 'default',
      'default_currency': AppConstants.defaultCurrency,
      'exchange_rate': AppConstants.defaultExchangeRate,
      'alert_days_30': AppConstants.alertDays30,
      'alert_days_7': AppConstants.alertDays7,
      'alert_days_1': AppConstants.alertDays1,
      'enable_notifications': 1,
    });
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  Future<String> getDatabaseFilePath() async {
    final dbPath = await getDatabasesPath();
    return join(dbPath, AppConstants.databaseName);
  }
}
