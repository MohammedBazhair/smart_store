import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/product_provider.dart';

class ProductNameField extends ConsumerWidget {
  const ProductNameField({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Autocomplete<String>(
      optionsBuilder: (textEditingValue) async {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }

        final suggestions = await ref
            .read(productSearchControllerProvider.notifier)
            .searchProductsNamesSuggestions(
              textEditingValue.text,
            );

        return suggestions.toSet();
      },
      onSelected: (option) {
        controller.text = option;
      },
      fieldViewBuilder: (
        context,
        textEditingController,
        focusNode,
        onFieldSubmitted,
      ) {
        // مزامنة أولية فقط
        textEditingController.value = controller.value;

        return TextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          textInputAction: TextInputAction.next,
          onChanged: (value) {
            controller.value = textEditingController.value;
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
        );
      },
    );
  }
}
