import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/product_provider.dart';
import 'product_filter_dialog.dart';

class ProductSearchBar extends ConsumerStatefulWidget {
  const ProductSearchBar({
    super.key,
  });

  @override
  ConsumerState<ProductSearchBar> createState() => _ProductSearchBarState();
}

class _ProductSearchBarState extends ConsumerState<ProductSearchBar> {
  final _controller = SearchController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
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
                          onPressed: () {
                            _controller.clear();
                            ref
                                .read(productQueryProvider.notifier)
                                .update((q) => q.copyWith(search: ''));
                          },
                        )
                      : child!;
                },
                child: const SizedBox.shrink(),
              ),
            ),
            onChanged: (value) {
              ref
                  .read(productQueryProvider.notifier)
                  .update((q) => q.copyWith(search: value.trim()));
              ref.read(productSearchProvider.notifier).search();
            },
          ),
        ),
        const _ProductFilterAction(),
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
          ref.read(productQueryProvider.notifier).update(
                (q) => q.copyWith(category: category),
              );
          ref.read(productSearchProvider.notifier).search();
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
          ref.read(productQueryProvider.notifier).update(
                (q) => q.copyWith(clearCategory: true),
              );
        }
        _showFilterDialog(context, ref);
      },
    );
  }
}
