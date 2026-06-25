import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/shared/presentation/controllers/app_ui_event_controller.dart';
import '../../../../../core/shared/providers/ui_providers.dart';
import '../../../../store/data/models/store_member_key.dart';
import '../../../../store/domain/entities/store.dart';
import '../../../../user/domain/entities/role.dart';
import '../../data/admin_store_repository.dart';
import '../providers/admin_stores_provider.dart';

class AdminStoresNotifier extends StreamNotifier<List<Store>> {
  AdminStoreRepository get _repository =>
      ref.read(adminStoreRepositoryProvider);

  AppUiEventController get _uiEvent => ref.read(appUiEventProvider.notifier);

  @override
  Stream<List<Store>> build() {
    return _repository.getAllStores();
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
      return e.toString();
    }
  }
}
