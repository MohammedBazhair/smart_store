import '../../../../core/database/remote/remote_database_service.dart';
import '../../../../errors/result.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/seller_product.dart';
import '../models/global_product_model.dart';
import '../models/seller_product_model.dart';

abstract class ProductRemoteDataSource {
  Future<Result<List<Category>>> getAllCategories();
  Future<Result<List<SellerProduct>>> getSellerProducts(String sellerId);
  Future<Result<SellerProduct>> getProductById(String sellerProductId);
  Future<Result<Product?>> getProductByBarcode({
    required String barcode,
    required String sellerId,
  });
  Future<bool> isBarcodeExists(String barcode);
  Future<Result<List<SellerProduct>>> searchProducts({
    required String query,
    required String sellerId,
  });
  Future<Result<List<SellerProduct>>> getExpiredProducts(
    String sellerId,
  );
  Future<Result<List<SellerProduct>>> getNearExpiryProducts(
    String sellerId,
    int days,
  );
  Future<Result<void>> addProduct(SellerProduct product);
  Future<Result<void>> updateProduct(SellerProduct product);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  ProductRemoteDataSourceImpl(this._client);
  final RemoteDatabaseService _client;

  @override
  Future<Result<List<Category>>> getAllCategories() async {
    try {
      final response = await _client.readRows(table: 'categories');
      final categories = response.map(Category.fromRemote).toList();
      return SuccessState(categories);
    } catch (e) {
      return ErrorState(e.toString());
    }
  }

  @override
  Future<Result<List<SellerProduct>>> getSellerProducts(String sellerId) async {
    try {
      final response = await _client.client
          .from('seller_products')
          .select(
            '*, global_products(*, categories(*))',
          )
          .eq('seller_id', sellerId);

      final products = response.map(SellerProductModel.fromRemote).toList();
      return SuccessState(products);
    } catch (e) {
      return ErrorState(e.toString());
    }
  }

  @override
  Future<Result<SellerProduct>> getProductById(String sellerProductId) async {
    try {
      final response = await _client.client
          .from('seller_products')
          .select(
            '*, global_products(*, categories(*))',
          )
          .eq('id', sellerProductId);
      final map = response.first;
      return SuccessState(SellerProductModel.fromRemote(map));
    } catch (e) {
      return ErrorState(e.toString());
    }
  }

  @override
  Future<Result<Product?>> getProductByBarcode({
    required String barcode,
    required String sellerId,
  }) async {
    try {
      if (!await isBarcodeExists(barcode)) return const SuccessState(null);

      final result = await _client.client
          .from('seller_products')
          .select(
            '*, global_products(*, categories(*))',
          )
          .eq('barcode', barcode)
          .eq('seller_id', sellerId)
          .single();

      if (result.isNotEmpty) {
        final product = SellerProductModel.fromRemote(result);
        return SuccessState(product);
      }

      final globalProductMap = (await _getGlobalProductByBarcode(barcode))!;
      final globalProduct = GlobalProductModel.fromRemote(globalProductMap);
      return SuccessState(globalProduct);
    } catch (e) {
      return ErrorState(e.toString());
    }
  }

  Future<Map<String, dynamic>?> _getGlobalProductByBarcode(
    String barcode,
  ) async {
    final response = await _client.client
        .from('global_products')
        .select('*, categories(*)')
        .eq('barcode', barcode);

    return response.firstOrNull;
  }

  @override
  Future<bool> isBarcodeExists(String barcode) async {
    try {
      final response = await _getGlobalProductByBarcode(barcode);

      return response != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Result<List<SellerProduct>>> searchProducts({
    required String query,
    required String sellerId,
  }) async {
    try {
      final response = await _client.client
          .from('seller_products')
          .select(
            '*, global_products(*, categories(*))',
          )
          .eq('seller_id', sellerId)
          .ilike('name', '%$query%');

      final products = response.map(SellerProductModel.fromRemote).toList();
      return SuccessState(products);
    } catch (e) {
      return ErrorState(e.toString());
    }
  }

  @override
  Future<Result<List<SellerProduct>>> getExpiredProducts(
    String sellerId,
  ) async {
    try {
      final today = DateTime.now().toIso8601String();
      final response = await _client.client
          .from('seller_products')
          .select(
            '*, global_products(*, categories(*))',
          )
          .eq('seller_id', sellerId)
          .lte('expiry_date', today);

      final products = response.map(SellerProductModel.fromRemote).toList();
      return SuccessState(products);
    } catch (e) {
      return ErrorState(e.toString());
    }
  }

  @override
  Future<Result<List<SellerProduct>>> getNearExpiryProducts(
    String sellerId,
    int days,
  ) async {
    try {
      final now = DateTime.now();
      final near = now.add(Duration(days: days));
      final response = await _client.client
          .from('seller_products')
          .select(
            '*, global_products(*, categories(*))',
          )
          .eq('seller_id', sellerId)
          .gte('expiry_date', now.toIso8601String())
          .lte('expiry_date', near.toIso8601String());

      final products = response.map(SellerProductModel.fromRemote).toList();
      return SuccessState(products);
    } catch (e) {
      return ErrorState(e.toString());
    }
  }

  @override
  Future<Result<void>> addProduct(SellerProduct product) async {
    try {
      if (!await isBarcodeExists(product.globalProduct.barcode ?? '')) {
        final globalProductMap =
            GlobalProductModel.fromEntity(product.globalProduct).toMap();
        await _client.insertRow(
          map: globalProductMap,
          table: 'global_products',
        );
      }
      final sellerProductMap = SellerProductModel.fromEntity(product).toMap();

      await _client.insertRow(map: sellerProductMap, table: 'seller_products');
      return const SuccessState(null);
    } catch (e) {
      return ErrorState(e.toString());
    }
  }

  @override
  Future<Result<void>> updateProduct(SellerProduct product) async {
    try {
      final map = SellerProductModel.fromEntity(product).toMap();
      await _client.update(
        column: 'id',
        id: product.id!,
        table: 'seller_products',
        updated: map,
      );
      return const SuccessState(null);
    } catch (e) {
      return ErrorState(e.toString());
    }
  }
}
