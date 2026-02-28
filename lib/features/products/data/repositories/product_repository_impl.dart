import '../../../../core/database/local/cache_service.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../errors/result.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
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
  Future<List<StoreProduct>> getAllProducts(String storeId) async {
    final hasConnection = await _connectivity.hasConnection();

    final result = hasConnection
        ? await _remoteDatabase.getSellerProducts(storeId)
        : await _localDatabase.getAllProducts(storeId);

    if (result is SuccessState<List<StoreProduct>>) return result.data;
    return [];
  }

  @override
  Future<Result<StoreProduct>> getProductById(String sellerProductId) async {
    try {
      final hasConnection = await _connectivity.hasConnection();

      final result = hasConnection
          ? await _remoteDatabase.getProductById(sellerProductId)
          : await _localDatabase.getProductById(sellerProductId);

      if (result is ErrorState) throw Exception();
      return result;
    } catch (e) {
      return const ErrorState('فشل في جلب المنتج');
    }
  }

  @override
  Future<Product?> getProductByBarcode({
    required String barcode,
    required String storeId,
  }) async {
    final hasConnection = await _connectivity.hasConnection();

    final result = hasConnection
        ? await _remoteDatabase.getProductByBarcode(
            storeId: storeId,
            barcode: barcode,
          )
        : await _localDatabase.getProductByBarcode(
            storeId: storeId,
            barcode: barcode,
          );

    if (result is SuccessState<Product?>) return result.data;
    return null;
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
  Future<Result<List<StoreProduct>>> getExpiredProducts(
    String storeId,
  ) async {
    try {
      final hasConnection = await _connectivity.hasConnection();

      final result = hasConnection
          ? await _remoteDatabase.getExpiredProducts(storeId)
          : await _localDatabase.getExpiredProducts(storeId);

      if (result is SuccessState<List<StoreProduct>>) {
        return SuccessState(result.data);
      }
      throw Exception();
    } catch (e) {
      return ErrorState(
        'فشل في جلب المنتجات المنتهية: ${e.toString()}',
      );
    }
  }

  @override
  Future<Result<List<StoreProduct>>> getNearExpiryProducts(
    String storeId,
    int days,
  ) async {
    try {
      final hasConnection = await _connectivity.hasConnection();

      final result = hasConnection
          ? await _remoteDatabase.getNearExpiryProducts(storeId, days)
          : await _localDatabase.getNearExpiryProducts(storeId, days);

      if (result is SuccessState<List<StoreProduct>>) {
        return SuccessState(result.data);
      }
      throw Exception();
    } catch (e) {
      return ErrorState(
        'فشل في جلب المنتجات القريبة من الانتهاء: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> isBarcodeExists(String barcode) async {
    final hasConnection = await _connectivity.hasConnection();
    final isExists = hasConnection
        ? await _remoteDatabase.isBarcodeExists(barcode)
        : await _localDatabase.isBarcodeExists(barcode);

    return isExists;
  }

  @override
  Future<Result<void>> addProduct(StoreProduct product) async {
    try {
      if (await _connectivity.hasConnection()) {
        await _remoteDatabase.addProduct(product);
      }

      await _localDatabase.addProduct(product);

      return const SuccessState(null);
    } catch (e) {
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
    final isDownloaded = _localCache.getBool(key: 'isDownloadedInit') ?? false;
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
  }
}
