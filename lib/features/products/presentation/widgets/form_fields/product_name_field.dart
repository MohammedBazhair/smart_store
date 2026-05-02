import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/product_provider.dart';

class ProductNameField extends ConsumerWidget {
  const ProductNameField({super.key, required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context, ref) {
    return Autocomplete<String>(
      optionsBuilder: (textEditingValue) async {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        final suggestions = await ref
            .read(productSearchControllerProvider.notifier)
            .searchProductsNamesSuggestions(textEditingValue.text);

        return suggestions.toSet();
      },
      onSelected: (option) {
        controller.text = option;
      },
      fieldViewBuilder: (_, textEditingController, focusNode, __) {
       WidgetsBinding.instance.addPostFrameCallback((_) {
          if (textEditingController.text != controller.text) {
            textEditingController.text = controller.text;
          }
        });
        return TextFormField(
          focusNode: focusNode,
          controller: textEditingController,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'اسم المنتج *',
            prefixIcon: Icon(Icons.inventory_2),
            helperText: '',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يرجى إدخال اسم المنتج';
            }
            return null;
          },
        );
      },
    );
  }
}
