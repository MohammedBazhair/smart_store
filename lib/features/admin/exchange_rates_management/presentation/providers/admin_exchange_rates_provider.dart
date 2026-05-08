import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/shared/providers/core_providers.dart';
import '../../data/admin_exchange_rates_repository.dart';

final adminExchangeRatesRepositoryProvider =
    Provider<AdminExchangeRatesRepository>((ref) {
  final supabase = ref.read(supabaseProvider);
  return AdminExchangeRatesRepository(supabase.client);
});

final adminExchangesRatesListProvider = FutureProvider((ref) {
  final repo = ref.read(adminExchangeRatesRepositoryProvider);
  return repo.getAllExchangesRates();
});
