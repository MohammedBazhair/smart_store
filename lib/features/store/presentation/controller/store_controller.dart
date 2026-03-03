import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/enums.dart';
import '../../../../core/constants/log.dart';
import '../../../../core/shared/providers/core_providers.dart';
import '../../../../errors/exceptions.dart';
import '../../../user/domain/entities/role.dart';
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
    final repo = ref.read(storeRepositoryProvider);
    final profile = ref.read(userControllerProvider).profile;
    final stores = await repo.getUserStores(profile.phone ?? '');

    final Map<String, StoreWithMembers> myStores = {};

    for (final s in stores) {
      final members = await repo.getStoreMembers(s.id!);
      final storeTest = StoreWithMembers(store: s, members: members);
      myStores[s.id!] = storeTest;
    }

    final newState = state.state.copyWith(
      myStores: myStores,
    );

    state = LoadMyStoresEvent(state: newState);
    Logger.debugLog(message: state.state.myStores.keys.toString());
  }

  Future<void> addStoreMember(String phoneNumber) async {
    try {
      final selectedStoreId = state.state.selectedStoreId;
      if (selectedStoreId == null) {
        throw const NoStoreSelectedException('لم يتم اختيار متجر');
      }

      final repo = ref.read(storeRepositoryProvider);
      final now = DateTime.now();
      final member = StoreMember(
        memberPhone: phoneNumber,
        storeId: selectedStoreId,
        role: Role.worker,
        createdAt: now,
        updatedAt: now,
      );

      await repo.addStoreMember(member);

      state = AddStoreMemberEvent(state: state.state, member: member);
    } on AppException catch (e) {
      state = ErrorStoreEvent(state: state.state, error: e.message);
    } catch (e) {
      state = ErrorStoreEvent(
        state: state.state,
        error: 'حدث خطأ أثناء إضافة العضو صاحب الرقم $phoneNumber',
      );
    }
  }

  Future<void> createStore(String storeName) async {
    try {
      final repo = ref.read(storeRepositoryProvider);
      final profile = ref.read(userControllerProvider).profile;
      final now = DateTime.now();

      final store = Store(
        name: storeName,
        ownerId: profile.userId,
        currency: Currency.YER,
        createdAt: now,
        updatedAt: now,
      );

      await repo.createStore(store, profile.phone!);

      state = CreateStoreEvent(state: state.state, storeName: storeName);

      await loadMyStores();
    } on AppException catch (e) {
      state = ErrorStoreEvent(
        state: state.state,
        error: e.message,
      );
    } catch (e) {
      Logger.debugLog(error: e);
      state = ErrorStoreEvent(
        state: state.state,
        error:
            'فشلت عملية إنشاء متجر تأكد من الاتصال بالانترنت او راجع الدعم الفني',
      );
    }
  }

  Future<void> selectStore(String storeId) async {
    final cache = ref.read(localCacheServiceProvider);
    await cache.setString(key: 'selected_store_id', value: storeId);
    state =
        SelectStoreEvent(state: state.state.copyWith(selectedStoreId: storeId));
  }
}
