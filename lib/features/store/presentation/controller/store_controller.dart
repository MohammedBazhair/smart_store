import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/log.dart';
import '../../../../core/database/local/cache_service.dart';
import '../../../../core/shared/providers/core_providers.dart';
import '../../../../errors/exceptions.dart';
import '../../../audio/presentation/controller/audio_provider.dart';
import '../../../settings/domain/entities/currence_code.dart';
import '../../../user/domain/entities/profile.dart';
import '../../../user/domain/entities/role.dart';
import '../../data/models/store_member_key.dart';
import '../../domain/entities/store.dart';
import '../../domain/entities/store_member.dart';
import '../../domain/repositories/store_repository.dart';
import 'store_provider.dart';
import 'store_state.dart';

class StoreController extends Notifier<StoreEventState> {
  @override
  StoreEventState build() {
    final selectedStoreId = _cache.getString(key: AppConstants.lastStoreIdKey);

    return InitialStoreEvent(
      state: StoreState(selectedStoreId: selectedStoreId),
    );
  }

  LocalCacheService get _cache => ref.read(localCacheServiceProvider);
  ProfileEntity get profile => ref.read(userControllerProvider).entity.profile;
  StoreRepository get storeRepo => ref.read(storeRepositoryProvider);

  StoreMember? get meAsCurrentMember {
    try {
      final storeId = state.state.selectedStoreId;
      final phone = profile.phone;

      if (storeId == null || phone == null) return null;

      final memberKey = StoreMemberKey(storeId: storeId, memberPhone: phone);
      final members = state.state.selectedStore?.members;
      return members?.firstWhere((m) => m.primaryKey == memberKey);
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      return null;
    }
  }

  Future<void> loadMyStores() async {
    state = LoadinMyStoresEvent(state: state.state);

    final repo = ref.read(storeRepositoryProvider);
    final stores = await repo.getUserStores(profile.phone ?? '');

    final futures = stores.map((s) async {
      final members = await repo.getStoreMembers(s.id!);
      final storeWithMembers = StoreWithMembers(store: s, members: members);
      return MapEntry(s.id!, storeWithMembers);
    });

    final entries = await Future.wait(futures);

    final myStores = Map.fromEntries(entries);

    final newState =
        state.state.copyWith(myStores: myStores, isInitialized: true);

    state = LoadMyStoresEvent(state: newState);
  }

  Future<String?> addStoreMember(String phoneNumber) async {
    try {
      final selectedStoreId = state.state.selectedStoreId;
      if (selectedStoreId == null) {
        throw const NoStoreSelectedException('لم يتم اختيار متجر');
      }

      final now = DateTime.now().toUtc();

      final member = StoreMember(
        primaryKey:
            StoreMemberKey(storeId: selectedStoreId, memberPhone: phoneNumber),
        role: Role.worker,
        createdAt: now,
        updatedAt: now,
        isDeleted: false,
      );

      await storeRepo.addStoreMember(member);

      await ref.read(audioControllerProvider.notifier).playScannerBeep();

      state = AddStoreMemberEvent(state: state.state, member: member);
      return null;
    } on AppException catch (e) {
      return e.message;
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      return 'حدث خطأ أثناء إضافة العضو صاحب الرقم $phoneNumber';
    }
  }

  Future<void> removeStoreMember(String phoneNumber) async {
    try {
      final memberKey = StoreMemberKey(
        storeId: state.state.selectedStoreId!,
        memberPhone: phoneNumber,
      );
      await storeRepo.removeStoreMember(memberKey);
    } on AppException catch (e) {
      state = ErrorStoreEvent(state: state.state, error: e.message);
    } catch (e) {
      state = ErrorStoreEvent(
        state: state.state,
        error: 'حدث خطأ أثناء إزالة العضو صاحب الرقم $phoneNumber',
      );
    }
  }

  Future<String?> createStore(String storeName) async {
    try {
      final now = DateTime.now().toUtc();

      final store = Store(
        name: storeName,
        ownerPhone: profile.phone!,
        currency: CurrencyCode.theDefault,
        createdAt: now,
        updatedAt: now,
        isDeleted: false,
      );

      final newStore = await storeRepo.createStore(store);
      final ownerMember = StoreMember(
        primaryKey:
            StoreMemberKey(storeId: newStore.id!, memberPhone: profile.phone!),
        role: Role.storeOwner,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
        isDeleted: false,
      );

      final storeWithMembers =
          StoreWithMembers(store: newStore, members: {ownerMember});

      final copiedStores = {
        ...state.state.myStores,
        newStore.id!: storeWithMembers,
      };

      Future.delayed(const Duration(seconds: 1), () {
        ref.read(audioControllerProvider.notifier).playSuccessResult();

        state = CreateStoreEvent(
          state: state.state.copyWith(myStores: copiedStores),
          storeName: storeName,
        );
      });

      return null;
    } on AppException catch (e) {
      return e.message;
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      return 'فشلت عملية إنشاء متجر تأكد من الاتصال بالانترنت او راجع الدعم الفني';
    }
  }

  Future<void> selectStore(String storeId) async {
    await _cache.setString(key: AppConstants.lastStoreIdKey, value: storeId);
    state =
        SelectStoreEvent(state: state.state.copyWith(selectedStoreId: storeId));
  }

  void unselectStores() {
    _cache.remove(key: AppConstants.lastStoreIdKey);
    state =
        UnSelectStoreEvent(state: state.state.copyWith(selectedStoreId: null));
  }
}
