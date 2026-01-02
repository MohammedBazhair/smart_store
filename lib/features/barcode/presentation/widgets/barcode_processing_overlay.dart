import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/presentation/widgets/common/conditional_builder.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

class BarcodeProcessingOverlay extends ConsumerWidget {
  const BarcodeProcessingOverlay({
    super.key,
  });

  @override
  Widget build(BuildContext context, ref) {
    final isProcessing = ref.watch(isLoadingProvider);

    return ConditionalBuilder(
      condition: isProcessing,
      builder: (context) => const CircularProgressIndicator(),
    );
  }
}
