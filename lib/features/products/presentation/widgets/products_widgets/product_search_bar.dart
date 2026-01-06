import 'package:flutter/material.dart';
import '../../../domain/product_query.dart';

class ProductSearchBar extends StatelessWidget {
  const ProductSearchBar({
    super.key,
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });
  final TextEditingController controller;
  final ProductQuery query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'بحث عن منتج...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: query.isSearching
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: onClear,
              )
            : null,
      ),
      onChanged: onChanged,
    );
  }
}
