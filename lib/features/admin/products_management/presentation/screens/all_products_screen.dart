import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/admin_products_provider.dart';

class AllProductsScreen extends ConsumerWidget {
  const AllProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(adminProductsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('جميع المنتجات'),
      ),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return const Center(child: Text('لا يوجد منتجات.'));
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final globalProduct = product['global_products'] as Map<String, dynamic>?;
              final name = globalProduct?['name'] ?? 'منتج غير معروف';
              final barcode = globalProduct?['barcode'] ?? 'لا يوجد باركود';
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.inventory_2),
                  title: Text(name),
                  subtitle: Text('الباركود: $barcode\nالسعر: ${product['price'] ?? 0} | الكمية: ${product['quantity'] ?? 0}'),
                  trailing: product['is_deleted'] == true
                      ? const Text('محذوف', style: TextStyle(color: Colors.red))
                      : const Text('متوفر', style: TextStyle(color: Colors.green)),
                  isThreeLine: true,
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
