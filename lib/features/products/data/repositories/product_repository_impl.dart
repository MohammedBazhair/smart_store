import '../../../../core/network/connectivity_service.dart';
import '../../../../errors/result.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/seller_product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasource/product_local_data_source.dart';
import '../datasource/product_remote_data_source.dart';

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
  Future<Result<List<Category>>> getAllCategories() async {
    final hasConnection = await _connectivity.hasConnection();
    final result = hasConnection
        ? await _remoteDatabase.getAllCategories()
        : await _localDatabase.getAllCategories();

    return result;
  }

  @override
  Future<List<SellerProduct>> getAllProducts(String sellerId) async {
    final hasConnection = await _connectivity.hasConnection();

    final result = hasConnection
        ? await _remoteDatabase.getSellerProducts(sellerId)
        : await _localDatabase.getAllProducts(sellerId);

    if (result is SuccessState<List<SellerProduct>>) return result.data;
    return [];
  }

  @override
  Future<Result<SellerProduct>> getProductById(String sellerProductId) async {
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
    required String sellerId,
  }) async {
    final hasConnection = await _connectivity.hasConnection();

    final result = hasConnection
        ? await _remoteDatabase.getProductByBarcode(
            sellerId: sellerId,
            barcode: barcode,
          )
        : await _localDatabase.getProductByBarcode(
            sellerId: sellerId,
            barcode: barcode,
          );

    if (result is SuccessState<Product?>) return result.data;
    return null;
  }

  @override
  Future<List<SellerProduct>> searchProducts({
    required String query,
    required String sellerId,
  }) async {
    final hasConnection = await _connectivity.hasConnection();

    final result = hasConnection
        ? await _remoteDatabase.searchProducts(
            query: query,
            sellerId: sellerId,
          )
        : await _localDatabase.searchProducts(
            query: query,
            sellerId: sellerId,
          );

    if (result is SuccessState<List<SellerProduct>>) {
      return result.data;
    }
    return [];
  }

  @override
  Future<Result<List<SellerProduct>>> getExpiredProducts(
    String sellerId,
  ) async {
    try {
      final hasConnection = await _connectivity.hasConnection();

      final result = hasConnection
          ? await _remoteDatabase.getExpiredProducts(sellerId)
          : await _localDatabase.getExpiredProducts(sellerId);

      if (result is SuccessState<List<SellerProduct>>) {
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
  Future<Result<List<SellerProduct>>> getNearExpiryProducts(
    String sellerId,
    int days,
  ) async {
    try {
      final hasConnection = await _connectivity.hasConnection();

      final result = hasConnection
          ? await _remoteDatabase.getNearExpiryProducts(sellerId, days)
          : await _localDatabase.getNearExpiryProducts(sellerId, days);

      if (result is SuccessState<List<SellerProduct>>) {
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
  Future<Result<void>> addProduct(SellerProduct product) async {
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
  Future<Result<void>> updateProduct(SellerProduct product) async {
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
}
