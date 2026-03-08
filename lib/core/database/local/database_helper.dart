import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
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
    final dbPath = await getExternalStorageDirectory();
    final path = join(dbPath!.path, filePath);

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
      category_id INTEGER PRIMARY KEY,
      category_name TEXT NOT NULL
    );
    ''');

    await db.execute('''
      CREATE TABLE exchange_rates ( 
        currency TEXT PRIMARY KEY, 
        rate_to_base INTEGER NOT NULL, 
        updated_at TEXT NOT NULL 
      );
    ''');

    await db.execute('''
      CREATE TABLE stores (
        id TEXT PRIMARY KEY,
        owner_phone TEXT NOT NULL,
        store_name TEXT NOT NULL,
        currency TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (owner_phone) REFERENCES profiles(phone) ON UPDATE CASCADE
        FOREIGN KEY (currency) REFERENCES exchange_rates(currency) ON UPDATE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE global_products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category_id INTEGER,
        barcode TEXT UNIQUE,
        created_at TEXT,
        FOREIGN KEY (category_id) REFERENCES categories(category_id)
      );
    ''');

    await db.execute('''
      CREATE TABLE store_members (
        member_phone TEXT NOT NULL,
        store_id TEXT NOT NULL,
        role TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (store_id) REFERENCES stores(id),
        FOREIGN KEY (member_phone) REFERENCES profiles(phone) ON UPDATE CASCADE,
        PRIMARY KEY (store_id, member_phone)
      );
    ''');

    await db.execute('''
      CREATE TABLE store_products (
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
        FOREIGN KEY (currency) REFERENCES exchange_rates(currency) ON UPDATE CASCADE,
        PRIMARY KEY (store_id, product_id)
      );
    ''');

    await db.execute('''
      CREATE TABLE sync_changes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        record_id TEXT NOT NULL,
        operation TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE sync_state (
        table_name TEXT PRIMARY KEY,
        last_sync TEXT NOT NULL
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

    await db.execute('''
      CREATE INDEX idx_store_member
      ON store_members(store_id, member_phone);
      CREATE INDEX idx_store
      ON stores(id);
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
