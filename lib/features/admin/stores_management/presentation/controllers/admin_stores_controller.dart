import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/shared/presentation/controllers/app_ui_event_controller.dart';
import '../../../../../core/shared/providers/ui_providers.dart';
import '../../../../store/data/models/store_member_key.dart';
import '../../../../store/domain/entities/store.dart';
import '../../../../store/domain/entities/store_member.dart';
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
    _storesSubscriptions =
        _repository.getAllStores().listen(_handleStoresChanges);
    _membersSubscriptions =
        _repository.getAllMembers().listen(_handleMembersChanges);

    return AdminStoresState(isLoading: true);
  }

  void _handleStoresChanges(Map<String, Store> stores) {}

  void _handleMembersChanges(List<StoreMember> members) {}

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
      return e.toString();
    }
  }
}
