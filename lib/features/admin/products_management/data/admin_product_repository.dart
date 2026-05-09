import 'package:supabase_flutter/supabase_flutter.dart';

class AdminProductRepository {
  AdminProductRepository(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    // نجلب المنتجات من store_products مع دمج بيانات global_products للحصول على الاسم والباركود
    final response = await _client.from('store_products').select('*, global_products(*)');
    return List<Map<String, dynamic>>.from(response);
  }
}
