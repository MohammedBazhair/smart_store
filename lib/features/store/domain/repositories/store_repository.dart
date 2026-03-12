import '../../data/models/store_member_key.dart';
import '../entities/store.dart';
import '../entities/store_member.dart';

abstract class StoreRepository {
  Future<Store> createStore(Store store);

  Future<List<Store>> getUserStores(String userPhone);

  Future<Set<StoreMember>> getStoreMembers(String storeId);

  Future<void> addStoreMember(StoreMember member);

  Future<void> removeStoreMember(StoreMemberKey key);

  Future<void> updateStore(Store store);

  Future<void> syncAll(String userPhone);

  Future<void> deleteStore(String storeId);
}
