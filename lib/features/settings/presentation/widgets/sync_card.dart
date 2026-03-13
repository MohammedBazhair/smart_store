import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/shared/presentation/widgets/common/conditional_builder.dart';
import '../../../../core/shared/presentation/widgets/loading/three_dots_loading.dart';
import '../../../../core/shared/providers/core_providers.dart';

class SyncCard extends StatelessWidget {
  const SyncCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'مزامنة البيانات',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 30),
            Consumer(
              builder: (_, ref, __) {
                final isLoading = ref.watch(appSyncLoadingProvider);
                return ElevatedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () async {
                          try {
                            ref.read(appSyncLoadingProvider.notifier).state =
                                true;

                            await ref.refresh(appSyncProvider.future);
                          } finally {
                            ref.read(appSyncLoadingProvider.notifier).state =
                                false;
                          }
                        },
                  icon: ConditionalBuilder(
                    condition: isLoading,
                    builder: (context) => const Text('جارٍ المزامنة'),
                    fallback: (context) => const Text('مزامنة'),
                  ),
                  label: ConditionalBuilder(
                    condition: isLoading,
                    builder: (context) => const ThreeDotsLoading(
                      dotSize: 4,
                      dotColor: Colors.black,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
