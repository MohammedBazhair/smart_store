import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/product_query.dart';
import '../../controllers/product_provider.dart';

class ProductsTabs extends ConsumerWidget {
  const ProductsTabs({
    super.key,
  });

  @override
  Widget build(BuildContext context, ref) {
    final query = ref.watch(productQueryProvider);

    return SizedBox(
      height: 50,
      child: ListView.separated(
        key: const PageStorageKey('products_tabs_scroll'),
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        scrollDirection: Axis.horizontal,
        itemCount: ProductSortType.values.length,
        itemBuilder: (context, index) {
          final type = ProductSortType.values[index];
          final isSelected = query.sortType == type;

          return ChoiceChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 5,
              children: [
                Icon(
                  type.icon,
                  size: 16,
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).primaryColor,
                ),
                Text(type.label),
              ],
            ),
            selected: isSelected,
            onSelected: (_) {
              ref
                  .read(productSearchProvider.notifier)
                  .search(query.copyWith(sortType: type));
            },
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : null,
              fontWeight: isSelected ? FontWeight.bold : null,
            ),
          );
        },
      ),
    );
  }
}
