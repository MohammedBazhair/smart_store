import 'package:flutter/material.dart';

import '../../../../core/extensions/extensions.dart';
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
            ElevatedButton.icon(
              onPressed: () => context.pushTo(const StoreSelectionScreen()),
              icon: const Icon(Icons.store),
              label: const Text('تغيير'),
            ),
          ],
        ),
      ),
    );
  }
}
