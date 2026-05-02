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
        return ValueListenableBuilder(
          valueListenable: controller,
          
          builder: (context, value, child) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (controller.text.isEmpty) textEditingController.clear();
            });
            return child!;
          },
          child: TextFormField(
            focusNode: focusNode,
            controller: textEditingController,
            textInputAction: TextInputAction.next,
            onChanged: (value) {
              controller.text = value;
            },
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
          ),
        );
      },
    );
  }
}
