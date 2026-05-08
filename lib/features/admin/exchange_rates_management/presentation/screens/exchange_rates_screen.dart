import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/admin_exchange_rates_provider.dart';

class ExchangesRatesScreen extends ConsumerWidget {
  const ExchangesRatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exchangeRatesAsync = ref.watch(adminExchangesRatesListProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('عملات التطبيق'),
      ),
      body: exchangeRatesAsync.when(
        data: (rates) {
          if (rates.isEmpty) {
            return const Center(child: Text('لا يوجد عملات.'));
          }

          return ListView.builder(
            itemCount: rates.length,
            itemBuilder: (context, index) {
              final rate = rates[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.store),
                  title: Text(rate.currency.label),
                  subtitle: Text('سعر الصرف: ${rate.rateToBase}'),
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
