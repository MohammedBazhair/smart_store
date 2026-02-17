import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../products/domain/entities/seller_product.dart';
import '../../../../settings/domain/settings.dart';
import '../../../../settings/presentation/controllers/settings_provider.dart';
import '../../../domain/barcode_scan_result.dart';
import 'product_price_content.dart';

Future<void> showProductPriceDialog({
  required BuildContext context,
  required BarcodeScanResult scanResult,
}) async {
  await showDialog(
    context: context,
    builder: (_) => ProviderScope(
      parent: ProviderScope.containerOf(context),
      child: ProductPriceDialog(scanResult: scanResult),
    ),
  );
}

class ProductPriceDialog extends ConsumerWidget {
  const ProductPriceDialog({super.key, required this.scanResult});
  final BarcodeScanResult scanResult;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(appSettingsProvider);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: settingsState.when(
          data: (settings) {
            final product = scanResult.product;
            if (product == null) {
              return const Text('هذا المنتج غير موجود');
            }

            return ProductPriceContent(
              product: product,
              settings: settings,
            );
          },
          loading: () => Skeletonizer(
            child: ProductPriceContent(
              product: SellerProduct.fake(),
              settings: Settings.theDefault(),
            ),
          ),
          error: (_, __) => const Text('خطأ في تحميل الإعدادات'),
        ),
      ),
    );
  }
}
