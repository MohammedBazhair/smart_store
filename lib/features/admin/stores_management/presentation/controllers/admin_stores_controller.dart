import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/log.dart';
import '../../../../../core/shared/presentation/controllers/app_ui_event_controller.dart';
import '../../../../../core/shared/providers/ui_providers.dart';
import '../../../../store/data/models/store_member_key.dart';
import '../../../../store/domain/entities/store.dart';
import '../../../../store/domain/entities/store_member.dart';
import '../../../../store/presentation/controller/store_state.dart';
import '../../../../user/domain/entities/role.dart';
import '../../data/admin_store_repository.dart';
import '../providers/admin_stores_provider.dart';
import 'admin_stores_state.dart';

class AdminStoresController extends Notifier<AdminStoresState> {
  AdminStoreRepository get _repository =>
      ref.read(adminStoreRepositoryProvider);

  AppUiEventController get _uiEvent => ref.read(appUiEventProvider.notifier);

  StreamSubscription<Map<String, Store>>? _storesSubscriptions;
  StreamSubscription<List<StoreMember>>? _membersSubscriptions;

  @override
  AdminStoresState build() {
    _storesSubscriptions = _repository
        .getAllStores()
        .listen(_handleStoresChanges, onError: _onError);
    _membersSubscriptions = _repository
        .getAllMembers()
        .listen(_handleMembersChanges, onError: _onError);

    return AdminStoresState(isLoading: true);
  }

  void _handleStoresChanges(Map<String, Store> stores) async {
    final copied = {...state.storeWithMembers};

    await Future.wait(
      stores.values.map((store) async {
        final storeId = store.id;
        if (storeId == null) return;
        copied.update(
          storeId,
          (value) => value.copyWith(store: store),
          ifAbsent: () {
            return StoreWithMembers(store: store, members: {});
          },
        );
      }),
    );

    state = state.copyWith(storeWithMembers: copied, isLoading: false);
  }

  void _handleMembersChanges(List<StoreMember> members) async {
    final copied = {...state.storeWithMembers};

    await Future.wait(
      members.map((member) async {
        copied.update(
          member.primaryKey.storeId,
          (value) {
            final oldMembers = value.members;
            return value.copyWith(members: {...oldMembers, member});
          },
        );
      }),
    );

    state = state.copyWith(storeWithMembers: copied, isLoading: false);
  }

  void _onError(Object e, StackTrace st) {
    Logger.debugLog(error: e, stackTrace: st);
    state = state.copyWith(isLoading: false, error: e.toString());
  }

  Future<void> deleteStore(String storeId) async {
    try {
      await _repository.deleteStore(storeId);
      _uiEvent.showSuccess('تم حذف هذا المتجر بنجاح');
    } catch (e) {
      _uiEvent.showError(e.toString());
    }
  }

  Future<String?> addMemberToStore({
    required StoreMemberKey memberKey,
    required Role role,
  }) async {
    try {
      await _repository.insertMember(memberKey, role);

      _uiEvent.showSuccess('تم إضافة العضو إلى المتجر بنجاح');
      return null;
    } catch (e) {
      Logger.debugLog(error: e);
      return e.toString();
    }
  }
}
