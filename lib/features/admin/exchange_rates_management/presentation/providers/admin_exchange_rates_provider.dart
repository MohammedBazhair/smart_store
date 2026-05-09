import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/shared/providers/core_providers.dart';
import '../../../../settings/presentation/controllers/settings_provider.dart';
import '../../data/admin_exchange_rates_repository.dart';
import 'admin_exchange_rates_controller.dart';
import 'admin_exchange_rates_state.dart';

final adminExchangeRatesRepositoryProvider =
    Provider<AdminExchangeRatesRepository>((ref) {
  final _remoteSettings = ref.read(remoteSettingDataSourceProvider);
  final _remoteDatabase = ref.read(remoteDatabaseServiceProvider);
  return AdminExchangeRatesRepository(_remoteSettings, _remoteDatabase);
});

final adminExchangeRatesControllerProvider =
    NotifierProvider<AdminExchangeRatesController, AdminExchangeRatesState>(
  AdminExchangeRatesController.new,
);