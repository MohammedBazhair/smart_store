import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/products/presentation/controllers/product_provider.dart';
import '../../../../features/settings/presentation/controllers/settings_provider.dart';
import '../../../../features/store/presentation/controller/store_provider.dart';
import '../../../constants/log.dart';
import '../../../utils/background_utils.dart';
import '../../providers/core_providers.dart';

class AppSyncController extends Notifier<bool> {
  @override
  bool build() => false;

  Future<void> sync({bool isManual = false}) async {
    if (state) return;

    state = true;
    try {
      await _loadLocal();

      if (!isManual) {
        // If not manual (like startup), we release the UI immediately after local load
        state = false;
        // Launch remote sync in background without awaiting it
        // ignore: unawaited_futures
        _performInternetSync();
        return;
      }

      // If manual, we wait for remote sync to finish while showing the loader
      await _performInternetSync();
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
    } finally {
      state = false;
    }
  }

  Future<void> _performInternetSync() async {
    try {
      final network = ref.read(networkProvider);
      if (await network.hasConnection()) {
        final backgroundUtils = BackgroundUtils(ref.container);
        await backgroundUtils.syncAllData();
        // Refresh local state after sync finishes
        await _loadLocal();
      }
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
    }
  }

  Future<void> _loadLocal() async {
    // 1. First load essential data (Profile and Exchange Rates)
    // These are required for foreign key constraints in other tables
       await ref.read(userControllerProvider.notifier).loadProfile();
   
      await ref.read(settingsRepositoryProvider).getExchangeRates();

    // 2. Load stores and products in parallel once prerequisites are available
    await ref.read(storeControllerProvider.notifier).loadMyStores();
    await ref.read(productControllerProvider.notifier).initialize();
  }
}
