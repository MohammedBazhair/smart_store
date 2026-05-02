import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/enums.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../controllers/product_provider.dart';
import 'product_filter_dialog.dart';

class ProductSearchBar extends ConsumerWidget {
  const ProductSearchBar({
    super.key,
    this.showFilter = true,
  });
  final bool showFilter;

  @override
  Widget build(BuildContext context, ref) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: ref
                .read(productSearchControllerProvider.notifier)
                .searchController,
            decoration: InputDecoration(
              hintText: 'بحث عن منتج...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Consumer(
                builder: (context, ref, child) {
                  final isSearching = ref
                      .watch(productQueryProvider.select((s) => s.isSearching));
                  return isSearching
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: ref
                              .read(productSearchControllerProvider.notifier)
                              .clearSearch,
                        )
                      : child!;
                },
                child: const SizedBox.shrink(),
              ),
            ),
            onChanged: (value) {
              final query = ref.read(productQueryProvider);
              ref
                  .read(productSearchControllerProvider.notifier)
                  .search(query.copyWith(search: value.trim()));
            },
          ),
        ),
        if (showFilter) const _ProductFilterAction(),
      ],
    );
  }
}

class _ProductFilterAction extends ConsumerWidget {
  const _ProductFilterAction();

  void _showFilterDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => ProductFilterDialog(
        initialCategory: ref.watch(productQueryProvider).category,
        onApply: (category) {
          final query = ref.read(productQueryProvider);
          ref
              .read(productSearchControllerProvider.notifier)
              .search(query.copyWith(category: category));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, ref) {
    final query = ref.watch(productQueryProvider);
    return IconButton(
      tooltip: query.hasCategory ? query.category?.name : 'فلترة المنتجات',
      icon: query.hasCategory
          ? const Icon(Icons.filter_list)
          : const Icon(Icons.filter_list_off_rounded),
      onPressed: () {
        if (query.hasCategory) {
          ref.read(productSearchControllerProvider.notifier).clearCategory();
          context.showSnakbar(
            'تم الغاء الفلترة بالفئات',
            type: SnackBarType.success,
          );
        } else {
          _showFilterDialog(context, ref);
        }
      },
    );
  }
}
