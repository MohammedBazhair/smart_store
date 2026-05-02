import 'package:flutter/material.dart';
import '../../../../core/extensions/extensions.dart';
import '../widgets/products_widgets/products_view.dart';
import 'upsert_product_screen.dart';


class ProductsScreen extends StatelessWidget {
  const ProductsScreen({
    super.key,
    this.title,
  });

  final String? title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? 'المنتجات'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: ProductsView(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushTo(const UpsertProductScreen()),
        child: const Icon(Icons.add_circle),
      ),
    );
  }
}
