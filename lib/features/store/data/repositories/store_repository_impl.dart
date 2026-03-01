import '../../../../core/network/connectivity_service.dart';
import '../../../../errors/exceptions.dart';
import '../../../user/domain/repositories/user_repository.dart';
import '../../domain/entities/store.dart';
import '../../domain/entities/store_member.dart';
import '../../domain/repositories/store_repository.dart';
import '../datasource/store_remote_data_source.dart';
import '../models/store_member_model.dart';
import '../models/store_model.dart';

class StoreRepositoryImpl implements StoreRepository {
  StoreRepositoryImpl(this.remote, this.userRepository, this.connectivityService);
  final StoreRemoteDataSource remote;
  final UserRepository userRepository;
  final ConnectivityService connectivityService;

  @override
  Future<void> createStore(Store store) {
    final model = StoreModel.fromEntity(store);
    return remote.createStore(model);
  }

  @override
  Future<List<Store>> getUserStores(String userPhone) {
    return remote.getUserStores(userPhone);
  }

  @override
  Future<Set<StoreMember>> getStoreMembers(String storeId) async {
    final members = await remote.getMembers(storeId);
    return members.toSet();
  }

  @override
  Future<void> addStoreMember(StoreMember member) async {
    if(!await connectivityService.hasConnection()) {
      throw const InternetException();
    }
    final isUserExist = await userRepository.isPhoneSignUp(member.memberPhone);

    if (!isUserExist) {
      throw const UserPhoneNotFoundException('رقم هاتف العضو غير مسجل');
    }

    final model = StoreMemberModel.fromEntity(member);

    return remote.insertMember(model);
  }

  @override
  Future<void> removeStoreMember(String memberId) {
    return remote.deleteMember(memberId);
  }
}
