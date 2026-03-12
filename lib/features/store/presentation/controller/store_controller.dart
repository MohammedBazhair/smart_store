import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/log.dart';
import '../../../../core/shared/providers/core_providers.dart';
import '../../../../errors/exceptions.dart';
import '../../../settings/domain/entities/currence_code.dart';
import '../../../user/domain/entities/role.dart';
import '../../data/models/store_member_key.dart';
import '../../domain/entities/store.dart';
import '../../domain/entities/store_member.dart';
import 'store_provider.dart';
import 'store_state.dart';

class StoreController extends Notifier<StoreEventState> {
  @override
  StoreEventState build() {
    final cache = ref.read(localCacheServiceProvider);
    final selectedStoreId = cache.getString(key: 'selected_store_id');

    return InitialStoreEvent(
      state: StoreState(selectedStoreId: selectedStoreId),
    );
  }

  Future<void> loadMyStores() async {
    state = LoadinMyStoresEvent(state: state.state);

    final repo = ref.read(storeRepositoryProvider);
    final profile = ref.read(userControllerProvider).profile;
    final stores = await repo.getUserStores(profile.phone ?? '');

    final futures = stores.map((s) async {
      final members = await repo.getStoreMembers(s.id!);
      final storeWithMembers =
          StoreWithMembers(store: s, members: members);
      return MapEntry(s.id!, storeWithMembers);
    });

    final entries = await Future.wait(futures);

    final myStores = Map.fromEntries(entries);

    final newState = state.state.copyWith(myStores: myStores);

    state = LoadMyStoresEvent(state: newState);
  }

  Future<String?> addStoreMember(String phoneNumber) async {
    try {
      final selectedStoreId = state.state.selectedStoreId;
      if (selectedStoreId == null) {
        throw const NoStoreSelectedException('لم يتم اختيار متجر');
      }

      final repo = ref.read(storeRepositoryProvider);
      final now = DateTime.now().toUtc();

      final member = StoreMember(
        memberPhone: phoneNumber,
        storeId: selectedStoreId,
        role: Role.worker,
        createdAt: now,
        updatedAt: now,
        isDeleted: false,
      );

      await repo.addStoreMember(member);

      state = AddStoreMemberEvent(state: state.state, member: member);
      return null;
    } on AppException catch (e) {
      return e.message;
    } catch (e) {
      Logger.debugLog(error: e);
      return 'حدث خطأ أثناء إضافة العضو صاحب الرقم $phoneNumber';
    }
  }

  Future<void> removeStoreMember(String phoneNumber) async {
    try {
      final repo = ref.read(storeRepositoryProvider);
      final memberKey = StoreMemberKey(
        storeId: state.state.selectedStoreId!,
        memberPhone: phoneNumber,
      );
      await repo.removeStoreMember(memberKey);
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
      final repo = ref.read(storeRepositoryProvider);
      final profile = ref.read(userControllerProvider).profile;
      final now = DateTime.now().toUtc();

      final store = Store(
        name: storeName,
        ownerPhone: profile.phone!,
        currency: CurrencyCode.theDefault,
        createdAt: now,
        updatedAt: now,
        isDeleted: false,
      );

      final newStore = await repo.createStore(store);
      final ownerMember = StoreMember(
        memberPhone: profile.phone!,
        storeId: newStore.id!,
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
        state = CreateStoreEvent(
          state: state.state.copyWith(myStores: copiedStores),
          storeName: storeName,
        );
      });

      return null;
    } on AppException catch (e) {
      return e.message;
    } catch (e) {
      Logger.debugLog(error: e);
      return 'فشلت عملية إنشاء متجر تأكد من الاتصال بالانترنت او راجع الدعم الفني';
    }
  }

  Future<void> selectStore(String storeId) async {
    final cache = ref.read(localCacheServiceProvider);
    await cache.setString(key: AppConstants.lastStoreIdKey, value: storeId);
    state =
        SelectStoreEvent(state: state.state.copyWith(selectedStoreId: storeId));
  }
}
