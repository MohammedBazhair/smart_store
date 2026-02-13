import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/enums.dart';
import '../../../../core/shared/presentation/widgets/common/conditional_builder.dart';
import '../../../../core/shared/presentation/widgets/common/loading_widget.dart';
import '../../../../core/shared/providers/ui_providers.dart';

class BarcodeProcessingOverlay extends ConsumerWidget {
  const BarcodeProcessingOverlay({
    super.key,
  });

  @override
  Widget build(BuildContext context, ref) {
    final isProcessing = ref.watch(isLoadingProvider(IsLoading.processBarcode));

    return ConditionalBuilder(
      condition: isProcessing,
      builder: (context) => const LoadingWidget(),
    );
  }
}
