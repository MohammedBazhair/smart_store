import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/enums.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/providers/ui_providers.dart';
import '../../../../errors/result.dart';
import '../../../barcode/presentation/screens/barcode_scanner_screen.dart';
import '../../../settings/domain/entities/currence_code.dart';
import '../../../store/presentation/controller/store_provider.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_details.dart';
import '../../domain/entities/store_product.dart';
import '../../domain/entities/sub_entities/global_product.dart';
import '../controllers/product_provider.dart';
import '../widgets/form_fields/product_barcode_field.dart';
import '../widgets/form_fields/product_category_dropdown.dart';
import '../widgets/form_fields/product_expiry_date_field.dart';
import '../widgets/form_fields/product_name_field.dart';
import '../widgets/form_fields/product_notes_field.dart';
import '../widgets/form_fields/product_price_field.dart';
import '../widgets/form_fields/product_quantity_field.dart';
import '../widgets/pick_date/show_expiry_date_picker.dart';
import '../widgets/save_product_button.dart';

/// شاشة إضافة منتج جديد
class UpesertProductScreen extends ConsumerStatefulWidget {
  const UpesertProductScreen({
    super.key,
    this.barcode,
    this.product,
    this.detailsType,
    this.isEditing = false,
  });
  final String? barcode;
  final Product? product;
  final ProductDetailsType? detailsType;
  final bool isEditing;

  @override
  ConsumerState<UpesertProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<UpesertProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();
  final _expiryDateController = TextEditingController();

  Category _selectedCategory = Category.undefined();
  CurrencyCode _selectedCurrency = CurrencyCode.theDefault;

  bool get isEditingProduct => widget.isEditing;

  @override
  void initState() {
    super.initState();
    _barcodeController.text = widget.barcode ?? '';

    _initializeFields();
    _requestFocusAfterEdit();
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

  void _initializeFields() {
    if (widget.product == null) return;

    final product = widget.product!;
    if (product is StoreProduct) {
      _nameController.text = product.globalProduct.name;
      _barcodeController.text = product.globalProduct.barcode ?? '';
      _quantityController.text = product.quantity?.toString() ?? '';
      _priceController.text = product.price.toString();
      _notesController.text = product.notes ?? '';

      _expiryDateController.text = product.expiryDate != null
          ? DateFormat('yyyy-MM-dd').format(product.expiryDate!)
          : '';
      _selectedCategory = product.globalProduct.category;
      _selectedCurrency = product.currency;
    } else if (product is GlobalProduct) {
      _nameController.text = product.name;

      _barcodeController.text = product.barcode ?? '';

      _selectedCategory = product.category;
    }
  }

  void _requestFocusAfterEdit() {
    if (widget.detailsType == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final focusNode = ref.read(focusNodesProvider)[widget.detailsType];
      if (focusNode != null && mounted) {
        FocusScope.of(context).requestFocus(focusNode);
      }
    });
  }

  StoreProduct _buildProductFromFields({StoreProduct? oldProduct}) {
    final storeId = ref.read(storeControllerProvider).state.selectedStoreId!;

    final now = DateTime.now();
    final globalProduct = GlobalProduct(
      category: _selectedCategory,
      name: _nameController.text.trim(),
      barcode: _barcodeController.text,
      createdAt: now,
    );
    return StoreProduct(
      storeId: storeId,
      quantity: int.tryParse(_quantityController.text),
      expiryDate: DateTime.tryParse(_expiryDateController.text),
      notes: _notesController.text,
      updatedAt: now,
      currency: _selectedCurrency,
      price: double.tryParse(_priceController.text) ?? 0,
      globalProduct: globalProduct,
    );
  }

  Future<void> _selectDate() async {
    final date = DateTime.tryParse(_expiryDateController.text);
    ref.read(expiryDateControllerProvider.notifier).setDate(date);

    await showExpiryDatePicker(context, ref);
    final picked = ref.watch(expiryDateControllerProvider).selectedDate;

    _expiryDateController.text = picked != null
        ? DateFormat('yyyy-MM-dd').format(picked)
        : _expiryDateController.text;

    ref.read(expiryDateControllerProvider.notifier).reset();
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
    if (!(_formKey.currentState?.validate() ?? false)) return;

    ref
        .read(isLoadingProvider(IsLoading.saveProduct).notifier)
        .update((_) => true);
    final controller = ref.read(productControllerProvider.notifier);

    final product = _buildProductFromFields();
    final result = await controller.addProduct(product);

    if (!mounted) return;

    if (result is SuccessState<void>) {
      context.showSnakbar('تم إضافة المنتج بنجاح', type: SnackBarType.success);
      _clearForm();
    } else if (result is ErrorState<int>) {
      context.showSnakbar(result.message, type: SnackBarType.error);
    }

    ref
        .read(isLoadingProvider(IsLoading.saveProduct).notifier)
        .update((_) => false);
  }

  Future<void> _onEditProduct() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    ref
        .read(isLoadingProvider(IsLoading.saveProduct).notifier)
        .update((_) => true);
    final controller = ref.read(productControllerProvider.notifier);

    final oldProduct = widget.product! as StoreProduct;
    final updatedProduct = _buildProductFromFields(oldProduct: oldProduct);

    final result = await controller.updateProduct(
      oldProduct: oldProduct,
      newProduct: updatedProduct,
    );

    ref
        .read(isLoadingProvider(IsLoading.saveProduct).notifier)
        .update((_) => false);

    if (!mounted) return;

    if (result is SuccessState<void>) {
      context.showSnakbar('تم تعديل المنتج بنجاح', type: SnackBarType.success);
      Navigator.pop(context);
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
