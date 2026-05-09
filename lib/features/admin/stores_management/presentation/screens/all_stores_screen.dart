import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../store/domain/entities/store.dart';
import '../providers/admin_stores_provider.dart';
import '../widgets/store_admin_card.dart';

class AllStoresScreen extends ConsumerWidget {
  const AllStoresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storesAsync = ref.watch(adminStoresListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('جميع المتاجر'),
      ),
      body: storesAsync.when(
        data: (stores) {
          if (stores.isEmpty) {
            return const Center(child: Text('لا يوجد متاجر.'));
          }

          return _StoresListView(stores: stores);
        },
        loading: () => _StoresListView(stores: Store.fakeStoresList),
        error: (error, stack) => Center(child: Text('خطأ: $error')),
      ),
    );
  }
}

class _StoresListView extends ConsumerWidget {
  const _StoresListView({
    required this.stores,
  });
  final List<Store> stores;

  @override
  Widget build(BuildContext context, ref) {
    return RefreshIndicator(
      onRefresh: () => ref.refresh(adminStoresListProvider.future),
      child: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: stores.length,
        itemBuilder: (context, index) {
          final store = stores[index];
          return StoreAdminCard(store: store);
        },
      ),
    );
  }
}
