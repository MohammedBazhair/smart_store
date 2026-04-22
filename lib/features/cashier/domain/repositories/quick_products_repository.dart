import '../../../products/data/models/store_product_key.dart';

abstract class QuickProductsRepository {
  Future<List<String>> getQuickProductsIds(String storeId);

  Future<void> addQuickProduct(StoreProductKey productKey);

  Future<void> removeQuickProduct(StoreProductKey productKey);

  Future<bool> isQuickProduct(StoreProductKey productKey);
}
