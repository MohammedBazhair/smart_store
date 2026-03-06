import '../entities/store.dart';
import '../entities/store_member.dart';

abstract class StoreRepository {
  Future<Store> createStore(Store store, String ownerPhone);

  Future<List<Store>> getUserStores(String userPhone);

  Future<Set<StoreMember>> getStoreMembers(String storeId);

  Future<void> addStoreMember(StoreMember member);

  Future<void> removeStoreMember({
    required String memberPhone,
    required String storeId,
  });
}
