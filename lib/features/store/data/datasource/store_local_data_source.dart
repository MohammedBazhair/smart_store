import '../../../../core/constants/log.dart';
import '../../../../core/database/local/local_database_service.dart';
import '../../../user/domain/entities/role.dart';
import '../models/store_member_model.dart';
import '../models/store_model.dart';

abstract class StoreLocalDataSource {
  /// إنشاء متجر
  Future<void> createStore(StoreModel store, String ownerPhone);

  /// جلب متاجر المستخدم
  Future<List<StoreModel>> getUserStores(String userPhone);

  /// جلب أعضاء متجر
  Future<List<StoreMemberModel>> getMembers(String storeId);

  /// إضافة عضو
  Future<void> insertMember(StoreMemberModel member);

  /// حذف عضو
  Future<void> deleteMember(String id);
  

}

class StoreLocalDataSourceImpl implements StoreLocalDataSource {
  StoreLocalDataSourceImpl(this._db);

  final LocalDatabaseService _db;

  @override
  Future<void> createStore(StoreModel store, String ownerPhone) async {
    try {
      final now = DateTime.now();
      final member = StoreMemberModel(
        memberPhone: ownerPhone,
        storeId: store.id!,
        role: Role.storeOwner,
        createdAt: now,
        updatedAt: now,
      );

      await _db.transaction((t) async {
        await t.insert('stores', store.toMap());
        await t.insert('store_members', member.toMap());
      });

      Logger.debugLog(message: 'تم انشاء المتجر');
    } catch (e) {
      Logger.debugLog(error: e);
    }
  }

  @override
  Future<List<StoreModel>> getUserStores(String userPhone) async {
    final result = await _db.readRows(
      table: 'stores',
    );

    final stores = result.map(StoreModel.fromMap);

    // بعد ذلك، تحقق أي متجر يحتوي على العضو
    final filtered = <StoreModel>[];
    for (var store in stores) {
      final members = await _db.readRowsWhere(
        table: 'store_members',
        filters: {'store_id': store.id!, 'member_phone': userPhone},
      );

      if (members.isNotEmpty) filtered.add(store);
    }

    return filtered;
  }

  @override
  Future<List<StoreMemberModel>> getMembers(String storeId) async {
    final result = await _db.readRowsWhere(
      table: 'store_members',
      filters: {'store_id': storeId},
    );

    return result.map(StoreMemberModel.fromMap).toList();
  }

  @override
  Future<void> insertMember(StoreMemberModel member) async {
    await _db.insertRow(
      table: 'store_members',
      map: member.toMap(),
    );
  }

  @override
  Future<void> deleteMember(String id) async {
    await _db.delete(
      table: 'store_members',
      id: id,
      column: 'member_id',
    );
  }
}
