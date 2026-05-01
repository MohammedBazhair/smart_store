abstract class SyncProductRepository {
  Future<void> initializeDataFromNetwork();
  Future<void> syncAllProducts([String? storeId]);
  Future<void> syncAllCategories();
}
