import 'package:flutter/material.dart';

import '../../../../core/database/local/database_helper.dart';
import '../../../../core/database/local/local_database_service.dart';
import '../../../../core/database/remote/remote_database_service.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../errors/exceptions.dart';
import '../../../../errors/result.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/seller_product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasource/product_local_data_source.dart';
import '../datasource/product_remote_data_source.dart';
import '../models/seller_product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(
    this._localDatabase,
    this._remoteDatabase,
    this._connectivity,
  );

  final ConnectivityService _connectivity;
  final ProductLocalDataSource _localDatabase;
  final ProductRemoteDataSource _remoteDatabase;

  @override
  Future<Result<List<SellerProduct>>> getAllProducts(String sellerId) async {
    final hasConnection = await _connectivity.hasConnection();

    final products = hasConnection
        ? await _remoteDatabase.getSellerProducts(sellerId)
        : await _localDatabase.getAllProducts();

    return products;
  }

  @override
  Future<Result<SellerProduct>> getProductById(String id) async {
    try {
      if (await _connectivity.hasConnection()) {
        final result = await _remoteDatabase.getProductById(id);
        return result;
      } else {
        final result = await _localDatabase.getProductById(id);
        return result;
      }
    } catch (e) {
      return const ErrorState('فشل في جلب المنتج');
    }
  }

  @override
  Future<SellerProduct?> getProductByBarcode(String barcode) async {
    final hasConnection = await _connectivity.hasConnection();

    final result = hasConnection
        ? await _remoteDatabase.getProductByBarcode(barcode)
        : await _localDatabase.getProductByBarcode(barcode);

    return (result is SuccessState<SellerProduct?>) ? result.data : null;
  }

  @override
  Future<Result<List<SellerProduct>>> searchProducts(String query) async {
    try {

      
      final db = await ;
      final maps = await db.query(
        'products',
        where: 'LOWER(name) LIKE LOWER(?) OR LOWER(barcode) LIKE LOWER(?)',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'created_at DESC',
      );
      final products = maps.map(SellerProductModel.fromMap).toList();
      return SuccessState(products);
    } catch (e) {
      return ErrorState('فشل في البحث: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<SellerProduct>>> filterProductsByCategory(
    String category,
  ) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'products',
        where: 'category = ?',
        whereArgs: [category],
        orderBy: 'created_at DESC',
      );
      final products = maps.map(SellerProductModel.fromMap).toList();
      return SuccessState(products);
    } catch (e) {
      return ErrorState('فشل في التصفية: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<SellerProduct>>> getExpiredProducts() async {
    try {
      final db = await _dbHelper.database;
      final now = DateTime.now().toIso8601String();
      final maps = await db.query(
        'products',
        where: 'expiry_date < ?',
        whereArgs: [now],
        orderBy: 'expiry_date ASC',
      );
      final products = maps.map(SellerProductModel.fromMap).toList();
      return SuccessState(products);
    } catch (e) {
      return ErrorState(
        'فشل في جلب المنتجات المنتهية: ${e.toString()}',
      );
    }
  }

  @override
  Future<Result<List<SellerProduct>>> getNearExpiryProducts(int days) async {
    try {
      final db = await _dbHelper.database;
      final now = DateTime.now();
      final threshold = now.add(Duration(days: days)).toIso8601String();
      final maps = await db.query(
        'products',
        where: 'DATE(expiry_date) BETWEEN DATE(?) AND DATE(?)',
        whereArgs: [threshold, now.toIso8601String()],
        orderBy: 'expiry_date ASC',
      );
      final products = maps.map(SellerProductModel.fromMap).toList();
      return SuccessState(products);
    } catch (e) {
      return ErrorState(
        'فشل في جلب المنتجات القريبة من الانتهاء: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> isBarcodeExists(String barcode) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'products',
      where: 'barcode = ?',
      whereArgs: [barcode],
    );
    return result.isNotEmpty;
  }

  @override
  Future<Result<int>> addProduct(SellerProduct product) async {
    try {
      final barcode = product.barcode;
      if (barcode == null) throw ArgumentError();

      if (await isBarcodeExists(barcode)) {
        throw const DuplicateBarcodeException();
      }

      final db = await _dbHelper.database;
      final model = SellerProductModel.fromEntity(product);

      final id = await db.insert('products', model.toMap());
      return SuccessState(id);
    } on ArgumentError {
      return const ErrorState(
        'فشل في إضافة المنتج: لم يتم تحديد الباركود',
      );
    } on DuplicateBarcodeException catch (e) {
      return ErrorState(e.message);
    } catch (e) {
      return ErrorState('فشل في إضافة المنتج: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> updateProduct(SellerProduct product) async {
    try {
      final db = await _dbHelper.database;

      final model = SellerProductModel.fromEntity(product);
      await db.update(
        'products',
        model.toMap(),
        where: 'id = ?',
        whereArgs: [product.id],
      );
      return const SuccessState(null);
    } catch (e) {
      return const ErrorState('فشل في تحديث المنتج');
    }
  }

  @override
  Future<Result<void>> deleteProduct(int id) async {
    try {
      final db = await _dbHelper.database;
      await db.delete(
        'products',
        where: 'id = ?',
        whereArgs: [id],
      );
      return const SuccessState(null);
    } catch (e) {
      return ErrorState('فشل في حذف المنتج: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> deleteAllProducts() async {
    try {
      final db = await _dbHelper.database;
      await db.delete('products');
      return const SuccessState(null);
    } catch (e) {
      return ErrorState('فشل في حذف جميع المنتجات: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<Category>>> getAllCategories() {
    // TODO: implement getAllCategories
    throw UnimplementedError();
  }
}
