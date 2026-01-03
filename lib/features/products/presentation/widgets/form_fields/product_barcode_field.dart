import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/utils/permissions.dart';
import '../../../domain/product_details.dart';
import '../../screens/add_product_screen.dart';

class ProductBarcodeField extends ConsumerWidget {
  const ProductBarcodeField({
    super.key,
    required this.controller,
    required this.onScan,
  });
  final TextEditingController controller;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context, ref) {
    return TextFormField(
      focusNode: ref.read(focusNodesProvider)[ProductDetailsType.barcode],
      controller: controller,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: InputDecoration(
        labelText: 'كود المنتج (باركود)',
        prefixIcon: const Icon(Icons.qr_code),
        suffixIcon: IconButton(
          icon: const Icon(Icons.qr_code_scanner),
          onPressed: () async {
            final hasPermission = await PermissionsService.requestCamera();
            if (hasPermission) return onScan();
            context.showSnakbar('يجب أولا أخذ صلاحية الكاميرا لاستعمال الماسح');
          },
        ),
        helperText: '',
      ),
    );
  }
}
