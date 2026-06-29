import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/log.dart';
import '../../../../../core/shared/presentation/controllers/app_ui_event_controller.dart';
import '../../../../../core/shared/providers/ui_providers.dart';
import '../../../../../core/utils/debouncer.dart';
import '../../../../store/data/models/store_member_key.dart';
import '../../../../user/domain/entities/role.dart';
import '../../data/admin_store_repository.dart';
import '../../domain/entities/user_search_result.dart';
import '../providers/admin_stores_provider.dart';
import 'admin_stores_state.dart';

class AdminStoresController extends Notifier<AdminStoresState> {
  final _searchDebounce = Debouncer(milliseconds: 800);

  AdminStoreRepository get _repository =>
      ref.read(adminStoreRepositoryProvider);

  AppUiEventController get _uiEvent => ref.read(appUiEventProvider.notifier);

  @override
  AdminStoresState build() {
    Future.microtask(_loadStores);
    return AdminStoresState(isLoading: true);
  }

  void _loadStores() async {
    final result = await _repository.getStoresWithMembers();

    state = state.copyWith(storeWithMembers: result, isLoading: false);
  }

  Future<void> deleteStore(String storeId) async {
    try {
      await _repository.deleteStore(storeId);
      _uiEvent.showSuccess('تم حذف هذا المتجر بنجاح');
    } catch (e) {
      _uiEvent.showError(e.toString());
    }
  }

  Future<String?> addSelectedUserToStore({
    required String storeId,
    required Role role,
  }) async {
    try {
      final selected = state.selectedUser;
      if (selected == null) return 'لم يتم تحديد مستخدم بعد';

      state = state.copyWith(isLoading: true);

      final memberKey =
          StoreMemberKey(storeId: storeId, memberPhone: selected.phone);

      final insertedMember = await _repository.insertMember(memberKey, role);

      final copied = {...state.storeWithMembers};
      copied.update(
        storeId,
        (storeWithMembers) {
          final copiedMembers = {...storeWithMembers.members, insertedMember};
          return storeWithMembers.copyWith(members: copiedMembers);
        },
      );
      state = state.copyWith(storeWithMembers: copied);

      _uiEvent.showSuccess('تم إضافة العضو إلى المتجر بنجاح');
      return null;
    } catch (e) {
      Logger.debugLog(error: e);
      return e.toString();
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void selectUser(UserSearchResult userResult) {
    if (userResult.userId == state.selectedUser?.userId) return;
    state = state.copyWith(selectedUser: userResult);
  }

  void searchMembersByPhone(String queryPhone) {
    _searchDebounce.dispose();

    _searchDebounce.run(() async {
      state = state.copyWith(isLoading: true);
      final results = await _repository.searchUsers(queryPhone);

      if (!ref.mounted) return;
      state = state.copyWith(resultsUsersSearch: results);
      state = state.copyWith(isLoading: false);
    });
  }
}
