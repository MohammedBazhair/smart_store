import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/admin_stores_provider.dart';

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

          return ListView.builder(
            itemCount: stores.length,
            itemBuilder: (context, index) {
              final store = stores[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.store),
                  title: Text(store['name'] ?? 'بدون اسم'),
                  subtitle: Text('رقم المالك: ${store['owner_phone'] ?? 'غير متوفر'}'),
                  trailing: store['is_deleted'] == true
                      ? const Text('محذوف', style: TextStyle(color: Colors.red))
                      : const Text('نشط', style: TextStyle(color: Colors.green)),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('خطأ: $error')),
      ),
    );
  }
}
