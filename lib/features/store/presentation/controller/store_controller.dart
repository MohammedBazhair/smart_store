import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/log.dart';
import '../../../../core/database/local/cache_service.dart';
import '../../../../core/shared/domain/entities/permission.dart';
import '../../../../core/shared/domain/services/permission_service.dart';
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
    final isLogged = ref.watch(userControllerProvider).entity.isLogged;

    if (!isLogged) {
      _cache.remove(key: AppConstants.lastStoreIdKey);
      return const InitialStoreEvent();
    }

    final selectedStoreId = _cache.getString(key: AppConstants.lastStoreIdKey);

    return InitialStoreEvent(
      state: StoreState(selectedStoreId: selectedStoreId),
    );
  }

  LocalCacheService get _cache => ref.read(localCacheServiceProvider);
  ProfileEntity get profile => ref.read(userControllerProvider).entity.profile;
  StoreRepository get _storeRepo => ref.read(storeRepositoryProvider);

  StoreMember? _getCurrentMember() {
    try {
      final storeId = state.state.selectedStoreId;
      final phone = ref.read(userControllerProvider).entity.profile.phone;

      if (storeId == null || phone == null) return null;

      final store = state.state.myStores[storeId];
      if (store == null) return null;

      final key = StoreMemberKey(
        storeId: storeId,
        memberPhone: phone,
      );

      return store.members.firstWhere(
        (m) => m.primaryKey == key,
      );
    } catch (_) {
      return null;
    }
  }

  bool _can(PermissionTask task) {
    final member = _getCurrentMember();
    final profile = ref.read(userControllerProvider).entity.profile;

    final permission = PermissionService(
      role: member?.role ?? Role.guest,
      accountStatus: profile.accountStatus,
    );

    return permission.can(task);
  }

  Future<void> loadMyStores() async {
    state = LoadinMyStoresEvent(state: state.state);

    final stores = await _storeRepo.getUserStores(profile.phone ?? '');

    final Map<String, StoreWithMembers> myStores = {};

    for (final s in stores) {
      final members = await _storeRepo.getStoreMembers(s.id!);

      final storeWithMembers = StoreWithMembers(store: s, members: members);
      myStores[s.id!] = storeWithMembers;
    }

    final newState =
        state.state.copyWith(myStores: myStores, isInitialized: true);

    state = LoadMyStoresEvent(state: newState);
  }

  Future<String?> addStoreMember(String phoneNumber) async {
    try {
      final hasPermission = _can(PermissionTask.editStoreDetails);
      if (!hasPermission) return 'لا توجد لديك صلاحيات إضافة عضو جديد للمتجر';
      state = AddingStoreEvent(state: state.state);
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

      await _storeRepo.addStoreMember(member);

      await ref.read(audioControllerProvider.notifier).playSuccessResult();

      final copiedMembers = Set.of(state.state.selectedStore!.members);
      copiedMembers.add(member);

      final myCopiedStores = {...state.state.myStores};
      myCopiedStores.update(
        selectedStoreId,
        (storeWithMembers) => storeWithMembers.copyWith(members: copiedMembers),
      );
      state = AddStoreMemberEvent(
        state: state.state.copyWith(myStores: myCopiedStores),
        member: member,
      );
      return null;
    } on AppException catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      state = ErrorStoreEvent(state: state.state, error: e.message);
      return e.message;
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      final errorMessage = 'حدث خطأ أثناء إضافة العضو صاحب الرقم $phoneNumber';
      state = ErrorStoreEvent(state: state.state, error: errorMessage);
      return errorMessage;
    }
  }

  Future<bool> removeStoreMember(String phoneNumber) async {
    try {
      final hasPermission = _can(PermissionTask.editStoreDetails);

      if (!hasPermission) {
        throw const PermissionsException('لا توجد لديك صلاحية إزالة عضو');
      }
      final memberKey = StoreMemberKey(
        storeId: state.state.selectedStoreId!,
        memberPhone: phoneNumber,
      );
      await _storeRepo.removeStoreMember(memberKey);

      final copiedMembers = Set.of(state.state.selectedStore!.members);
      copiedMembers.removeWhere((m) => m.primaryKey == memberKey);

      final myCopiedStores = {...state.state.myStores};
      myCopiedStores.update(
        memberKey.storeId,
        (storeWithMembers) => storeWithMembers.copyWith(members: copiedMembers),
      );

      state = RemoveStoreMemberEvent(
        state: state.state.copyWith(myStores: myCopiedStores),
      );
      return true;
    } on AppException catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      state = ErrorStoreEvent(state: state.state, error: e.message);
      return false;
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      state = ErrorStoreEvent(
        state: state.state,
        error: 'حدث خطأ أثناء إزالة العضو صاحب الرقم $phoneNumber',
      );
      return false;
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

      final newStore = await _storeRepo.createStore(store);
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
        if (!ref.mounted) return;
        ref.read(audioControllerProvider.notifier).playSuccessResult();

        state = CreateStoreEvent(
          state: state.state.copyWith(myStores: copiedStores),
          storeName: storeName,
        );
      });

      return null;
    } on AppException catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      state = ErrorStoreEvent(state: state.state, error: e.message);
      return e.message;
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      const errorMessage =
          'فشلت عملية إنشاء متجر تأكد من الاتصال بالانترنت او راجع الدعم الفني';
      state = ErrorStoreEvent(state: state.state, error: errorMessage);
      return errorMessage;
    }
  }

  Future<bool> updateSelectedStore(String storeName) async {
    try {
      if (!state.state.isSelectedStore) {
        throw const NoStoreSelectedException(
          'يجب تحديد متجر اولا لتتمكن من تعديله',
        );
      }

      final hasPermission = _can(PermissionTask.editStoreDetails);
      if (!hasPermission) {
        throw const PermissionsException(
          'لا توجد لديك صلاحيات تعديل بيانات المتجر',
        );
      }

      state = UpdateingStoreEvent(state: state.state);

      final selectedStore = state.state.selectedStore;

      if (selectedStore?.store.name == storeName) return false;
      final now = DateTime.now().toUtc();

      final updatedStore =
          selectedStore!.store.copyWith(name: storeName, updatedAt: now);

      await _storeRepo.updateStore(updatedStore);

      final copiedStores = {
        ...state.state.myStores,
      };

      final storeWithMembers = StoreWithMembers(
        store: updatedStore,
        members: state.state.selectedStore!.members,
      );

      copiedStores.update(
        updatedStore.id!,
        (_) => storeWithMembers,
      );

      state = UpdateStoreEvent(
        state: state.state.copyWith(myStores: copiedStores),
        storeName: storeName,
      );
      await ref.read(audioControllerProvider.notifier).playSuccessResult();
      return true;
    } on AppException catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      state = ErrorStoreEvent(state: state.state, error: e.message);
      return false;
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      state = ErrorStoreEvent(
        state: state.state,
        error:
            'فشلت عملية تعديل المتجر تأكد من الاتصال بالانترنت او راجع الدعم الفني',
      );
      return false;
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
