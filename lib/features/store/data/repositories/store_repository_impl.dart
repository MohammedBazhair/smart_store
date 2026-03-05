import 'package:uuid/uuid.dart';

import '../../../../core/network/connectivity_service.dart';
import '../../../../errors/exceptions.dart';
import '../../../user/domain/repositories/user_repository.dart';
import '../../domain/entities/store.dart';
import '../../domain/entities/store_member.dart';
import '../../domain/repositories/store_repository.dart';
import '../datasource/store_local_data_source.dart';
import '../datasource/store_remote_data_source.dart';
import '../models/store_member_model.dart';
import '../models/store_model.dart';

class StoreRepositoryImpl implements StoreRepository {
  StoreRepositoryImpl(
    this.local,
    this.remote,
    this.userRepository,
    this.connectivityService,
  );
  final StoreRemoteDataSource remote;
  final StoreLocalDataSource local;
  final UserRepository userRepository;
  final ConnectivityService connectivityService;

  @override
  Future<void> createStore(Store store, String ownerPhone) async {
    try {
      final newStore = store.copyWith(id: const Uuid().v4());
      final model = StoreModel.fromEntity(newStore);
      await remote.createStore(model);

      await local.createStore(model, ownerPhone);
    } catch (e) {
      if (e.toString().contains('enough credits')) {
        throw const CreditsZeroException(
          'يجب ان يكون معك عملة واحدة على الاقل لانشاء متجر',
        );
      }
      rethrow;
    }
  }

  @override
  Future<List<Store>> getUserStores(String userPhone) async {
    final hasConnection = await connectivityService.hasConnection();

    return hasConnection
        ? await remote.getUserStores(userPhone)
        : await local.getUserStores(userPhone);
  }

  @override
  Future<Set<StoreMember>> getStoreMembers(String storeId) async {
    final hasConnection = await connectivityService.hasConnection();
    final members = hasConnection
        ? await remote.getMembers(storeId)
        : await local.getMembers(storeId);

    return members.toSet();
  }

  @override
  Future<void> addStoreMember(StoreMember member) async {
    if (!await connectivityService.hasConnection()) {
      throw const InternetException();
    }
    final isUserExist = await userRepository.isPhoneSignUp(member.memberPhone);

    if (!isUserExist) {
      throw const UserPhoneNotFoundException(
        'رقم هاتف العضو غير مسجل في التطبيق',
      );
    }

    final model = StoreMemberModel.fromEntity(member);

    await remote.insertMember(model);
    await local.insertMember(model);
  }

  @override
  Future<void> removeStoreMember(String memberId) async {
    if (!await connectivityService.hasConnection()) {
      throw const InternetException();
    }

    await remote.deleteMember(memberId);
    await local.deleteMember(memberId);
  }
}
