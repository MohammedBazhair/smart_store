import 'package:flutter/material.dart';

class ProductExpiryDateField extends StatefulWidget {
  const ProductExpiryDateField({
    super.key,
    required this.controller,
    required this.onSelectDate,
  });
  final TextEditingController controller;
  final VoidCallback onSelectDate;

  @override
  State<ProductExpiryDateField> createState() => _ProductExpiryDateFieldState();
}

class _ProductExpiryDateFieldState extends State<ProductExpiryDateField> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) return;

      _focusNode.unfocus();
      widget.onSelectDate();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      keyboardType: TextInputType.none,
      decoration: const InputDecoration(
        labelText: 'تاريخ الانتهاء *',
        floatingLabelBehavior: FloatingLabelBehavior.always,
        prefixIcon: Icon(Icons.calendar_today),
        helperText: '',
        hint: Text('اختر التاريخ'),
      ),
       validator: (value) {
        if (value == null || value.isEmpty) {
          return 'يرجى إدخال تاريخ انتهاء المنتج';
        }
        return null;
      },
    );
  }
}
