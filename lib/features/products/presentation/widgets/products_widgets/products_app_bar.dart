import 'package:flutter/material.dart';

class ProductsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ProductsAppBar({super.key, required this.onFilterTap});
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('المنتجات'),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: onFilterTap,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
