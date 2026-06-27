import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/shared/providers/ui_providers.dart';
import '../../../../store/domain/entities/store.dart';
import '../../../../store/presentation/controller/store_state.dart';
import '../providers/admin_stores_provider.dart';
import '../widgets/store_admin_card.dart';

class AllStoresScreen extends ConsumerWidget {
  const AllStoresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(appUiEventProvider, (_, state) {
      if (state == null) return;
      context.showSnakbar(state.message, type: state.type);
    });
    final storesState = ref.watch(adminStoresControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('جميع المتاجر'),
      ),
      body: storesState.error == null
          ? Skeletonizer(
              enabled: storesState.isLoading,
              child: _StoresListView(
                storesWithMembers: storesState.isLoading
                    ? Store.fakeStoresWithMembersList
                    : storesState.storeWithMembers.values.toList(),
              ),
            )
          : Center(child: Text('خطأ: ${storesState.error}')),
    );
  }
}

class _StoresListView extends ConsumerWidget {
  const _StoresListView({
    required this.storesWithMembers,
  });
  final List<StoreWithMembers> storesWithMembers;

  @override
  Widget build(BuildContext context, ref) {
    if (storesWithMembers.isEmpty) {
      return const Center(child: Text('لا يوجد متاجر.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: storesWithMembers.length,
      itemBuilder: (context, index) {
        final store = storesWithMembers[index];
        return StoreAdminCard(storeWithMembers: store);
      },
    );
  }
}
