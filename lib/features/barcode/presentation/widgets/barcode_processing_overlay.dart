import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/presentation/widgets/common/conditional_builder.dart';
import '../../../../core/shared/presentation/widgets/loading/three_dots_loading.dart';
import '../controllers/barcode_provider.dart';

class BarcodeProcessingOverlay extends ConsumerWidget {
  const BarcodeProcessingOverlay({
    super.key,
  });

  @override
  Widget build(BuildContext context, ref) {
    final isProcessing = ref.watch(barcodeControllerProvider).isProcessing;

    return ConditionalBuilder(
      condition: isProcessing,
      builder: (context) => const ThreeDotsLoading(),
    );
  }
}
