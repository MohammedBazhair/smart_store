import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../../core/shared/presentation/controllers/app_ui_event_controller.dart';
import '../../../../settings/domain/entities/exchange_rate.dart';
import '../providers/admin_exchange_rates_provider.dart';
import '../widgets/exchange_rate_card.dart';

class ExchangesRatesScreen extends ConsumerStatefulWidget {
  const ExchangesRatesScreen({super.key});

  @override
  ConsumerState<ExchangesRatesScreen> createState() =>
      _ExchangesRatesScreenState();
}

class _ExchangesRatesScreenState extends ConsumerState<ExchangesRatesScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref
          .read(adminExchangeRatesControllerProvider.notifier)
          .fetchExchangeRates();
    });
  }

  @override
  Widget build(BuildContext context) {
    listenToUiEvents(context, ref);

    final state = ref.watch(adminExchangeRatesControllerProvider);

    final rates = state.rates.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('أسعار الصرف'),
      ),
      body: state.isLoading
          ? Skeletonizer(
              child: _RatesListView(
                rates: ExchangeRate.fakeList,
              ),
            )
          : rates.isEmpty
              ? const Center(
                  child: Text('لا توجد أسعار صرف'),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await ref
                        .read(
                          adminExchangeRatesControllerProvider.notifier,
                        )
                        .fetchExchangeRates();
                  },
                  child: _RatesListView(rates: rates),
                ),
    );
  }
}

class _RatesListView extends StatelessWidget {
  const _RatesListView({
    required this.rates,
  });

  final List<ExchangeRate> rates;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: rates.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        return ExchangeRateCard(
          rate: rates[index],
        );
      },
    );
  }
}
