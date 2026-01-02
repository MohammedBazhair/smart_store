import 'package:flutter/material.dart';

class ProductTitle extends StatelessWidget {
  const ProductTitle(this.name, {super.key});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }
}
