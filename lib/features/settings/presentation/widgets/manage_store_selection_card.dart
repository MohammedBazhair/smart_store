import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/presentation/widgets/common/hint_row.dart';
import '../../../store/presentation/controller/store_provider.dart';
import '../../../store/presentation/screens/store_details_screen.dart';
import '../../../store/presentation/screens/store_selection_screen.dart';
import '../../../store/presentation/widgets/store_card.dart';

class ManageStoreSelectionCard extends ConsumerWidget {
  const ManageStoreSelectionCard({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final selectedStore =
        ref.watch(storeControllerProvider.select((s) => s.state.selectedStore));
    final hasSelectedStore = selectedStore != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          spacing: 24,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    spacing: 20,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ادارة المتاجر',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (hasSelectedStore)
                        const HintRow(
                          message: 'اضغط على المتجر للانتقال لتفاصيل المتجر',
                          iconData: Icons.touch_app_outlined,
                        ),
                    ],
                  ),
                ),
                IconButton.filled(
                  onPressed: () => context.pushTo(const StoreSelectionScreen()),
                  icon: const Icon(
                    Icons.store,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            hasSelectedStore
                ? StoreCard(
                    store: selectedStore.store,
                    owner: selectedStore.owner,
                    membersLength: selectedStore.members.length,
                    onPressed: () {
                      context.pushTo(
                        StoreDetailsScreen(storeId: selectedStore.store.id),
                      );
                    },
                  )
                : const EmptyStoresView(),
          ],
        ),
      ),
    );
  }
}
