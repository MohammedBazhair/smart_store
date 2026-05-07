import 'package:supabase_flutter/supabase_flutter.dart';

class AdminStoreRepository {
  AdminStoreRepository(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> getAllStores() async {
    final response = await _client.from('stores').select();
    return List<Map<String, dynamic>>.from(response);
  }
}
