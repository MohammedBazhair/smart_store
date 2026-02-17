import '../../../../core/database/remote/remote_database_service.dart';
import '../../../../errors/result.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/seller_product.dart';
import '../models/seller_product_model.dart';

abstract class ProductRemoteDataSource {
  Future<Result<List<Category>>> getAllCategories();
  Future<Result<List<SellerProduct>>> getSellerProducts(String sellerId);
  Future<Result<SellerProduct>> getProductById(String id);
  Future<Result<SellerProduct?>> getProductByBarcode(String barcode);
  Future<bool> isBarcodeExists(String barcode);
  Future<Result<List<SellerProduct>>> searchProducts(String query);
  Future<Result<List<SellerProduct>>> filterProductsByCategory(
      String categoryKey);
  Future<Result<List<SellerProduct>>> getExpiredProducts();
  Future<Result<List<SellerProduct>>> getNearExpiryProducts(int days);
  Future<Result<int>> addProduct(SellerProduct product);
  Future<Result<void>> updateProduct(SellerProduct product);
  Future<Result<void>> deleteProduct(int id);
  Future<Result<void>> deleteAllProducts();
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  ProductRemoteDataSourceImpl(this._client);
  final RemoteDatabaseService _client;

  @override
  Future<Result<List<Category>>> getAllCategories() async {
    try {
      final response = await _client.readRows(table: 'categories');
      final categories = response.map(Category.fromMap).toList();
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

      final products = response.map(SellerProductModel.fromMap).toList();
      return SuccessState(products);
    } catch (e) {
      return ErrorState(e.toString());
    }
  }

  @override
  Future<Result<SellerProduct>> getProductById(int id) async {
    try {
      final response = await _client.client
          .from('global_products')
          .select('*, categories(*)')
          .eq('product_id', id)
          .limit(1)
          .single();
      return SuccessState(SellerProductModel.fromMap(response));
    } catch (e) {
      return ErrorState(e.toString());
    }
  }

  @override
  Future<Result<SellerProduct?>> getProductByBarcode(String barcode) async {
    try {
      final response = await client
          .from('products')
          .select('*, categories(*)')
          .eq('barcode', barcode)
          .maybeSingle();
      if (response == null) return Result.success(null);
      return Result.success(SellerProduct.fromMap(response));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<bool> isBarcodeExists(String barcode) async {
    final response =
        await client.from('products').select('id').eq('barcode', barcode);
    return (response as List).isNotEmpty;
  }

  @override
  Future<Result<List<SellerProduct>>> searchProducts(String query) async {
    try {
      final response = await client
          .from('products')
          .select('*, categories(*)')
          .ilike('name', '%$query%');
      final products = (response as List).map(SellerProduct.fromMap).toList();
      return Result.success(products);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<List<SellerProduct>>> filterProductsByCategory(
    String categoryKey,
  ) async {
    try {
      final response = await client
          .from('products')
          .select('*, categories(*)')
          .eq('categories.key', categoryKey);
      final products = (response as List).map(SellerProduct.fromMap).toList();
      return Result.success(products);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<List<SellerProduct>>> getExpiredProducts() async {
    try {
      final today = DateTime.now().toIso8601String();
      final response = await client
          .from('products')
          .select('*, categories(*)')
          .lte('expiry_date', today);
      final products = (response as List).map(SellerProduct.fromMap).toList();
      return Result.success(products);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<List<SellerProduct>>> getNearExpiryProducts(int days) async {
    try {
      final now = DateTime.now();
      final near = now.add(Duration(days: days));
      final response = await client
          .from('products')
          .select('*, categories(*)')
          .gte('expiry_date', now.toIso8601String())
          .lte('expiry_date', near.toIso8601String());
      final products = (response as List).map(SellerProduct.fromMap).toList();
      return Result.success(products);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<int>> addProduct(SellerProduct product) async {
    try {
      final map = SellerProductModel.fromEntity(product).toMap();
      final response = await client.from('products').insert(map).select();
      final insertedId = (response as List).first['id'] as int;
      return Result.success(insertedId);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<void>> updateProduct(SellerProduct product) async {
    try {
      final map = SellerProductModel.fromEntity(product).toMap();
      await client.from('products').update(map).eq('id', product.id);
      return Result.success(null);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<void>> deleteProduct(int id) async {
    try {
      await client.from('products').delete().eq('id', id);
      return Result.success(null);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<void>> deleteAllProducts() async {
    try {
      await client.from('products').delete();
      return Result.success(null);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}
