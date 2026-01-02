import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/utils/permissions.dart';

class ProductBarcodeField extends StatelessWidget {
  const ProductBarcodeField({
    super.key,
    required this.controller,
    required this.onScan,
    required this.isReadOnly,
  });
  final TextEditingController controller;
  final VoidCallback onScan;
  final bool isReadOnly;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.next,
      readOnly: isReadOnly,
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
