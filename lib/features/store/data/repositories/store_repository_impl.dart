import '../../domain/entities/store_member.dart';
import '../../domain/repositories/store_repository.dart';
import '../datasource/store_remote_data_source.dart';
import '../models/store_member_model.dart';

class StoreRepositoryImpl implements StoreRepository {
  StoreRepositoryImpl(this.remote);
  final StoreRemoteDataSource remote;

  @override
  Future<List<StoreMember>> getStoreMembers(String storeId) {
    return remote.getMembers(storeId);
  }

  @override
  Future<void> addStoreMember(StoreMember member) {
    final model = StoreMemberModel.fromEntity(member);

    return remote.insertMember(model);
  }

  @override
  Future<void> removeStoreMember(String memberId) {
    return remote.deleteMember(memberId);
  }
}
