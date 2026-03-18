import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../audio/presentation/controller/audio_provider.dart';
import '../../../store/presentation/screens/store_selection_screen.dart';

class ChangeStoreSelectionCard extends StatelessWidget {
  const ChangeStoreSelectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'اختيار متجر جديد',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 30),
            Consumer(
              builder: (_, ref, __) {
                return ElevatedButton.icon(
                  onPressed: () {
                    ref
                        .read(audioControllerProvider.notifier)
                        .playButtonClick();

                    context.pushTo(const StoreSelectionScreen());
                  },
                  icon: const Icon(Icons.store),
                  label: const Text('تغيير'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
