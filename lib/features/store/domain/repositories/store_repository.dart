import '../entities/store.dart';
import '../entities/store_member.dart';

abstract class StoreRepository {
  Future<Store> createStore(Store store);

  Future<List<Store>> getUserStores(String userPhone);

  Future<Set<StoreMember>> getStoreMembers(String storeId);

  Future<void> addStoreMember(StoreMember member);

  Future<void> removeStoreMember({
    required String memberPhone,
    required String storeId,
  });

  Future<void> updateStore(Store store);

  Future<void> syncStores(String userPhone);

  Future<void> pushStoresChanges();
  Future<void> pushMembersChanges();
  Future<void> syncAll(String userPhone);

  Future<void> deleteStore(String storeId);
}
