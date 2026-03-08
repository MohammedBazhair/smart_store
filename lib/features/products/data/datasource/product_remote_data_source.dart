import '../../../../core/constants/log.dart';
import '../../../../core/constants/typedef.dart';
import '../../../../core/database/remote/remote_database_service.dart';
import '../../../../errors/result.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/store_product.dart';
import '../../domain/entities/sub_entities/global_product.dart';
import '../models/global_product_model.dart';
import '../models/store_product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<Map<String, dynamic>>> getGlobalProducts();
  Future<Result<List<Category>>> getAllCategories();
  Future<Result<ModelsProductsByIdentifier>> getStoreProducts(String storeId);
  Future<Result<StoreProduct>> getProductById({
    required String productId,
    required String storeId,
  });
  Future<GlobalProduct?> getGlobalProductByBarcode(String barcode);
  Future<Result<List<StoreProduct>>> getExpiredProducts(
    String storeId,
  );
  Future<Result<List<StoreProduct>>> getNearExpiryProducts(
    String storeId,
    int days,
  );
  Future<Result<void>> addProduct(StoreProduct product);
  Future<Result<void>> updateProduct(StoreProduct product);
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
  Future<Result<ModelsProductsByIdentifier>> getStoreProducts(String storeId) async {
    try {
      final response = await _client.client
          .from('store_products')
          .select(
            '*, global_products(*, categories(*))',
          )
          .eq('store_id', storeId);

      final products = <String, StoreProductModel>{};

      for (final m in response) {
        final product = StoreProductModel.fromRemote(m);
        final key = product.globalProduct.barcode ?? product.globalProduct.id!;
        products[key] = product;
      }
      return SuccessState(products);
    } catch (e) {
      return ErrorState(e.toString());
    }
  }

  @override
  Future<Result<StoreProduct>> getProductById({
    required String productId,
    required String storeId,
  }) async {
    try {
      final response = await _client.client
          .from('store_products')
          .select(
            '*, global_products(*, categories(*))',
          )
          .eq('store_id', storeId)
          .eq('product_id', productId);
      final map = response.first;
      return SuccessState(StoreProductModel.fromRemote(map));
    } catch (e) {
      return ErrorState(e.toString());
    }
  }

  @override
  Future<GlobalProduct?> getGlobalProductByBarcode(
    String barcode,
  ) async {
    try {
      final response = await _client.client
          .from('global_products')
          .select('*, categories(*)')
          .eq('barcode', barcode);
      final globalProductMap = response.first;
      final globalProduct = GlobalProductModel.fromRemote(globalProductMap);
      return globalProduct;
    } catch (e) {
      Logger.debugLog(error: e);
      return null;
    }
  }



  @override
  Future<Result<List<StoreProduct>>> getExpiredProducts(
    String storeId,
  ) async {
    try {
      final today = DateTime.now().toUtc().toIso8601String();
      final response = await _client.client
          .from('store_products')
          .select(
            '*, global_products(*, categories(*))',
          )
          .eq('store_id', storeId)
          .lte('expiry_date', today);

      final products = response.map(StoreProductModel.fromRemote).toList();
      return SuccessState(products);
    } catch (e) {
      return ErrorState(e.toString());
    }
  }

  @override
  Future<Result<List<StoreProduct>>> getNearExpiryProducts(
    String storeId,
    int days,
  ) async {
    try {
      final now = DateTime.now().toUtc();
      final near = now.add(Duration(days: days));
      final response = await _client.client
          .from('store_products')
          .select(
            '*, global_products(*, categories(*))',
          )
          .eq('store_id', storeId)
          .gte('expiry_date', now.toIso8601String())
          .lte('expiry_date', near.toIso8601String());

      final products = response.map(StoreProductModel.fromRemote).toList();
      return SuccessState(products);
    } catch (e) {
      return ErrorState(e.toString());
    }
  }

  @override
  Future<Result<StoreProduct>> addProduct(StoreProduct product) async {
    try {
      final globalProduct =
          await getGlobalProductByBarcode(product.globalProduct.barcode ?? '');

      if (globalProduct == null) {
        final globalProductMap =
            GlobalProductModel.fromEntity(product.globalProduct).toMap();
        await _client.insertRow(
          map: globalProductMap,
          table: 'global_products',
        );
      }
      final storeProductMap = StoreProductModel.fromEntity(product).toMap();

      await _client.insertRow(
        map: storeProductMap,
        table: 'store_products',
      );

      return SuccessState(product);
    } catch (e) {
      Logger.debugLog(error: e);
      return ErrorState(e.toString());
    }
  }

  @override
  Future<Result<void>> updateProduct(
    StoreProduct product,
  ) async {
    try {
      final map = StoreProductModel.fromEntity(product).toMap();
      await _client.client
          .from('store_products')
          .update(map)
          .eq('product_id', product.globalProduct.id!)
          .eq('store_id', product.storeId);

      return const SuccessState(null);
    } catch (e) {
      return ErrorState(e.toString());
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getGlobalProducts() async {
    final result = await _client.client.from('global_products').select(
          '*, categories(*)',
        );

    return result;
  }
}
