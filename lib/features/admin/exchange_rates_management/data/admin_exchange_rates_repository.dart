import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../settings/data/models/exchange_rate_model.dart';
import '../../../settings/domain/entities/exchange_rate.dart';

class AdminExchangeRatesRepository {
  AdminExchangeRatesRepository(this._client);

  final SupabaseClient _client;

  Future<List<ExchangeRate>> getAllExchangesRates() async {
    final response = await _client.from('exchanges_rates').select();
    return response.map(ExchangeRateModel.fromMap).toList();
  }
}
