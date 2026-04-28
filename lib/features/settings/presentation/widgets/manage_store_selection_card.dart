import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../store/presentation/screens/store_selection_screen.dart';

class ManageStoreSelectionCard extends StatelessWidget {
  const ManageStoreSelectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'ادارة المتاجر',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 30),
            Consumer(
              builder: (_, ref, __) {
                return ElevatedButton.icon(
                  onPressed: () {
                    context.pushTo(const StoreSelectionScreen());
                  },
                  icon: const Icon(Icons.store),
                  label: const Text('ادارة المتاجر'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
