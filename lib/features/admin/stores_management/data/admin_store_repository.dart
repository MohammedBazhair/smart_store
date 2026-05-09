import '../../../../core/database/remote/remote_database_service.dart';
import '../../../store/data/models/store_model.dart';
import '../../../store/domain/entities/store.dart';

class AdminStoreRepository {
  AdminStoreRepository(this._remoteDatabase);

  final RemoteDatabaseService _remoteDatabase;

  Stream<List<Store>> getAllStores()  {
    final response =  _remoteDatabase.readRowsRealTime(table: 'stores', primaryKey: ['id']);
    return response.map((m)=> m.map(StoreModel.fromMap).toList());
  }
}
