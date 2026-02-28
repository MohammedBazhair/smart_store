import '../entities/store_member.dart';

abstract class StoreRepository {
  Future<List<StoreMember>> getStoreMembers(String storeId);

  Future<void> addStoreMember(StoreMember member);

  Future<void> removeStoreMember(String memberId);
}
