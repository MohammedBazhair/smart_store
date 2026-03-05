import 'package:uuid/uuid.dart';

import '../../../../core/constants/log.dart';
import '../../../../core/constants/typedef.dart';
import '../../../../core/database/local/cache_service.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../errors/result.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/store_product.dart';
import '../../domain/entities/sub_entities/global_product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasource/product_local_data_source.dart';
import '../datasource/product_remote_data_source.dart';
import '../models/global_product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(
    this._localDatabase,
    this._remoteDatabase,
    this._connectivity,
    this._localCache,
  );

  final ConnectivityService _connectivity;
  final LocalCacheService _localCache;
  final ProductLocalDataSource _localDatabase;
  final ProductRemoteDataSource _remoteDatabase;

  @override
  Future<List<Category>> getAllCategories() async {
    final hasConnection = await _connectivity.hasConnection();
    final result = hasConnection
        ? await _remoteDatabase.getAllCategories()
        : await _localDatabase.getAllCategories();

    if (result is SuccessState<List<Category>>) {
      await _localDatabase.saveAllCategories(result.data);
      return result.data;
    }

    return [];
  }

  @override
  Future<ProductsByIdentifier> getStoreProducts(String storeId) async {
    final hasConnection = await _connectivity.hasConnection();

    final result = hasConnection
        ? await _remoteDatabase.getStoreProducts(storeId)
        : await _localDatabase.getStoreProducts(storeId);

    if (result is SuccessState<ProductsByIdentifier>) return result.data;
    return {};
  }

  @override
  Future<Result<StoreProduct>> getProductById({
    required String productId,
    required String storeId,
  }) async {
    try {
      final hasConnection = await _connectivity.hasConnection();

      final result = hasConnection
          ? await _remoteDatabase.getProductById(
              productId: productId,
              storeId: storeId,
            )
          : await _localDatabase.getProductById(
              productId: productId,
              storeId: storeId,
            );

      if (result is ErrorState) throw Exception();
      return result;
    } catch (e) {
      return const ErrorState('فشل في جلب المنتج');
    }
  }

  @override
  Future<GlobalProduct?> getGlobalProductByBarcode(
    String barcode,
  ) async {
    final hasConnection = await _connectivity.hasConnection();

    final product = hasConnection
        ? await _remoteDatabase.getGlobalProductByBarcode(barcode)
        : await _localDatabase.getGlobalProductByBarcode(barcode);

    return product;
  }

  @override
  Future<List<StoreProduct>> searchProducts({
    required String query,
    required String storeId,
  }) async {
    final hasConnection = await _connectivity.hasConnection();

    final result = hasConnection
        ? await _remoteDatabase.searchProducts(
            query: query,
            storeId: storeId,
          )
        : await _localDatabase.searchProducts(
            query: query,
            storeId: storeId,
          );

    if (result is SuccessState<List<StoreProduct>>) {
      return result.data;
    }
    return [];
  }

  @override
  Future<List<StoreProduct>> getExpiredProducts(
    String storeId,
  ) async {
    try {
      final hasConnection = await _connectivity.hasConnection();

      final result = hasConnection
          ? await _remoteDatabase.getExpiredProducts(storeId)
          : await _localDatabase.getExpiredProducts(storeId);

      if (result is SuccessState<List<StoreProduct>>) {
        return result.data;
      }
      return [];
    } catch (e) {
      Logger.debugLog(error: e);
      return [];
    }
  }

  @override
  Future<List<StoreProduct>> getNearExpiryProducts(
    String storeId,
    int days,
  ) async {
    try {
      final hasConnection = await _connectivity.hasConnection();

      final result = hasConnection
          ? await _remoteDatabase.getNearExpiryProducts(storeId, days)
          : await _localDatabase.getNearExpiryProducts(storeId, days);

      if (result is SuccessState<List<StoreProduct>>) {
        return result.data;
      }
      return [];
    } catch (e) {
      Logger.debugLog(error: e);
      return [];
    }
  }

  @override
  Future<Result<StoreProduct>> addProduct(StoreProduct product) async {
    final barcode = product.globalProduct.barcode ?? '';
    final globalProduct = await getGlobalProductByBarcode(barcode);
    final globalProductId =
        globalProduct != null ? globalProduct.id : const Uuid().v4();

    final newProduct = product.copyWith(
      globalProduct: product.globalProduct.copyWith(id: globalProductId),
    );
    try {
      if (await _connectivity.hasConnection()) {
        await _remoteDatabase.addProduct(newProduct);
      }

      await _localDatabase.addProduct(newProduct);
      Logger.debugLog(message: newProduct.toString());
      return SuccessState(newProduct);
    } catch (e) {
      Logger.debugLog(error: e);
      return ErrorState('فشل في إضافة المنتج: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> updateProduct(StoreProduct product) async {
    try {
      final updatedProduct = product.copyWith(updatedAt: DateTime.now());
      if (await _connectivity.hasConnection()) {
        await _remoteDatabase.updateProduct(updatedProduct);
      }

      await _localDatabase.updateProduct(updatedProduct);
      return const SuccessState(null);
    } catch (e) {
      return const ErrorState('فشل في تحديث المنتج');
    }
  }

  @override
  Future<List<GlobalProduct>> getProductsGlobal() async {
    final hasConnection = await _connectivity.hasConnection();
    final rows = hasConnection
        ? await _remoteDatabase.getGlobalProducts()
        : await _localDatabase.getGlobalProducts();

    final products = rows.map(GlobalProductModel.fromRemote).toList();

    if (hasConnection) await _localDatabase.saveGlobalProducts(products);
    return products;
  }

  @override
  Future<void> initDataFromNetwork() async {
    try {
      final isDownloaded =
          _localCache.getBool(key: 'isDownloadedInit') ?? false;
      if (isDownloaded) return;

      if (!await _connectivity.hasConnection()) {
        throw Exception('No internet connection');
      }

      final categoriesResult = await getAllCategories();

      if (categoriesResult.isEmpty) {
        throw Exception('Categories not loaded');
      }

      await getProductsGlobal();

      await _localCache.setBool(key: 'isDownloadedInit', value: true);
    } catch (e) {
      Logger.debugLog(error: e);
    }
  }
}
