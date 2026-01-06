import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/providers/ui_providers.dart';
import '../../../barcode/presentation/screens/barcode_scanner_screen.dart';
import '../../domain/product.dart';
import '../../domain/product_details.dart';
import '../controllers/product_controller.dart';
import '../controllers/product_provider.dart';
import '../widgets/form_fields/product_barcode_field.dart';
import '../widgets/form_fields/product_category_dropdown.dart';
import '../widgets/form_fields/product_expiry_date_field.dart';
import '../widgets/form_fields/product_name_field.dart';
import '../widgets/form_fields/product_notes_field.dart';
import '../widgets/form_fields/product_price_field.dart';
import '../widgets/form_fields/product_quantity_field.dart';
import '../widgets/pick_date/show_expiry_date.dart';
import '../widgets/save_product_button.dart';


/// شاشة إضافة منتج جديد
class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({
    super.key,
    this.barcode,
    this.product,
    this.detailsType,
  });
  final String? barcode;
  final Product? product;
  final ProductDetailsType? detailsType;

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();
  final _expiryDateController = TextEditingController();

  ProductCategory _selectedCategory = ProductCategory.others;
  Currency _selectedCurrency = Currency.YER;

  bool get isEditingProduct => widget.product != null;

  @override
  void initState() {
    super.initState();
    _barcodeController.text = widget.barcode ?? '';

    if (!isEditingProduct) return;
    final product = widget.product!;

    _nameController.text = product.name;
    _quantityController.text = product.quantity?.toString() ?? '';
    _priceController.text = product.price.toString();
    _notesController.text = product.notes ?? '';
    _barcodeController.text = product.barcode ?? '';
    _expiryDateController.text = product.expiryDate != null
        ? DateFormat('yyyy-MM-dd').format(product.expiryDate!)
        : '';
    setState(() {
      _selectedCategory = product.category;
    });

    if (widget.detailsType == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final focusNode = ref.read(focusNodesProvider)[widget.detailsType];
      if (focusNode != null && mounted) {
        FocusScope.of(context).requestFocus(focusNode);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _barcodeController.dispose();
    _notesController.dispose();
    _priceController.dispose();
    _expiryDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = DateTime.tryParse(_expiryDateController.text);
    final picked = await showExpiryDatePicker(
      context,
      date,
    );

    _expiryDateController.text = picked != null
        ? DateFormat('yyyy-MM-dd').format(picked)
        : _expiryDateController.text;
  }

  Future<void> _scanBarcode() async {
    await HapticFeedback.selectionClick();

    final barcode = await context.pushTo<String?>(
      const BarcodeScannerScreen(
        isPopRequired: true,
      ),
    );

    _barcodeController.text = barcode ?? _barcodeController.text;
  }

  Future<void> _onAddProduct() async {
    final isFormValid = _formKey.currentState?.validate() ?? false;
    if (!isFormValid) return;

    ref
        .read(isLoadingProvider(IsLoading.saveProduct).notifier)
        .update((_) => true);

    final controller = ref.read(productControllerProvider.notifier);

    final product = Product(
      name: _nameController.text.trim(),
      quantity: int.tryParse(_quantityController.text),
      barcode: _barcodeController.text,
      expiryDate: DateTime.tryParse(_expiryDateController.text),
      category: _selectedCategory,
      notes: _notesController.text,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      currency: _selectedCurrency,
      price: double.tryParse(_priceController.text) ?? 0,
    );

    final result = await controller.addProduct(product);

    ref
        .read(isLoadingProvider(IsLoading.saveProduct).notifier)
        .update((_) => false);

    if (!context.mounted) return;

    if (result is SuccessState<int>) {
      context.showSnakbar('تم إضافة المنتج بنجاح', type: SnackBarType.success);
      _clearForm();
    } else if (result is ErrorState<int>) {
      context.showSnakbar(result.message, type: SnackBarType.error);
    }
  }

  Future<void> _onEditProduct() async {
    final isFormValid = _formKey.currentState?.validate() ?? false;
    if (!isFormValid) return;

    ref
        .read(isLoadingProvider(IsLoading.saveProduct).notifier)
        .update((_) => true);

    final controller = ref.read(productControllerProvider.notifier);
    log(_expiryDateController.text);
    final oldProduct = widget.product!;
    final updatedProduct = oldProduct.copyWith(
      name: _nameController.text.trim(),
      quantity: int.tryParse(_quantityController.text),
      barcode: _barcodeController.text,
      expiryDate: DateTime.tryParse(_expiryDateController.text),
      category: _selectedCategory,
      notes: _notesController.text,
      updatedAt: DateTime.now(),
      currency: _selectedCurrency,
      price: double.tryParse(_priceController.text),
    );

    final result = await controller.updateProduct(
      oldProduct: oldProduct,
      newProduct: updatedProduct,
    );

    ref
        .read(isLoadingProvider(IsLoading.saveProduct).notifier)
        .update((_) => false);

    if (!context.mounted) return;

    if (result is SuccessState<void>) {
      context.showSnakbar('تم تعديل المنتج بنجاح', type: SnackBarType.success);
      Navigator.pop(context);
      ref.invalidate(productsProvider);
    } else if (result is ErrorState<void>) {
      context.showSnakbar(result.message, type: SnackBarType.error);
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _quantityController.clear();
    _barcodeController.clear();
    _priceController.clear();
    _notesController.clear();
    _expiryDateController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isEditingProduct
            ? const Text('تعديل منتج')
            : const Text('إضافة منتج'),
      ),
      body: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                ProductNameField(controller: _nameController),
                ProductQuantityField(controller: _quantityController),
                ProductBarcodeField(
                  controller: _barcodeController,
                  onScan: _scanBarcode,
                ),
                ProductPriceField(
                  controller: _priceController,
                  currency: _selectedCurrency,
                  onCurrencyChanged: (currency) {
                    if (currency == null) return;
                    setState(() {
                      _selectedCurrency = currency;
                    });
                  },
                ),
                ProductExpiryDateField(
                  controller: _expiryDateController,
                  onSelectDate: _selectDate,
                ),
                ProductCategoryDropdown(
                  value: _selectedCategory,
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _selectedCategory = v);
                  },
                ),
                ProductNotesField(controller: _notesController),
                const SizedBox(height: 16),
                Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      flex: 2,
                      child: SaveProductButton(
                        onPressed:
                            isEditingProduct ? _onEditProduct : _onAddProduct,
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey.shade500,
                      ),
                      onPressed: _clearForm,
                      child: const Icon(
                        Icons.clear,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
