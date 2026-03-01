import '../entities/store.dart';
import '../entities/store_member.dart';

abstract class StoreRepository {
  Future<void> createStore(Store store);

  Future<List<Store>> getUserStores(String userPhone);

  Future<Set<StoreMember>> getStoreMembers(String storeId);

  Future<void> addStoreMember(StoreMember member);

  Future<void> removeStoreMember(String memberId);
}
