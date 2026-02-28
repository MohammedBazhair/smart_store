import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../constants/app_constants.dart';

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
      CREATE TABLE profiles (
      id TEXT PRIMARY KEY,
      user_name TEXT NOT NULL,
      account_status TEXT NOT NULL,
      phone TEXT UNIQUE,
      credits INTEGER NOT NULL DEFAULT 0,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    );
    ''');

    await db.execute('''
    CREATE TABLE categories (
      category_id int PRIMARY KEY,
      category_name TEXT NOT NULL
    );
    ''');

    await db.execute('''
      CREATE TABLE stores (
        id TEXT PRIMARY KEY,
        owner_id TEXT NOT NULL,
        store_name TEXT NOT NULL,
        currency TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (owner_id) REFERENCES profiles(id)
      );
    ''');

    await db.execute('''
      CREATE TABLE global_products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category_id int,
        barcode TEXT UNIQUE,
        created_at TEXT,
        FOREIGN KEY (category_id) REFERENCES categories(category_id)
      );
    ''');

    await db.execute('''
      CREATE TABLE store_members (
        id TEXT PRIMARY KEY,
        member_phone TEXT NOT NULL,
        store_id TEXT NOT NULL,
        role TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (store_id) REFERENCES stores(id),
        FOREIGN KEY (member_phone) REFERENCES profiles(phone),
        UNIQUE (store_id, member_phone)
      );
    ''');

    await db.execute('''
      CREATE TABLE store_products (
        id TEXT PRIMARY KEY,
        store_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        currency TEXT NOT NULL,
        expiry_date TEXT,
        notes TEXT,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (product_id) REFERENCES global_products(id),
        FOREIGN KEY (store_id) REFERENCES stores(id),
        UNIQUE (store_id, product_id)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS alerts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id TEXT NOT NULL,
        product_name TEXT NOT NULL,
        expiry_date TEXT NOT NULL,
        days_before_expiry INTEGER NOT NULL,
        importance TEXT NOT NULL,
        is_read INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        UNIQUE(product_id, expiry_date,days_before_expiry),
        FOREIGN KEY (product_id) REFERENCES global_products(id)
      )
    ''');
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
