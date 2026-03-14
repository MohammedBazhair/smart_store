import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/enums.dart';
import '../../../../core/shared/presentation/widgets/common/conditional_builder.dart';
import '../../../../core/shared/presentation/widgets/loading/three_dots_loading.dart';
import '../../../../core/shared/providers/ui_providers.dart';

class SaveProductButton extends ConsumerWidget {
  const SaveProductButton({
    super.key,
    required this.onPressed,
  });
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, ref) {
    final isLoading = ref.watch(isLoadingProvider(IsLoading.saveProduct));
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: ConditionalBuilder(
        condition: !isLoading,
        builder: (_) => const Text('حفظ المنتج'),
        fallback: (context) => const ThreeDotsLoading(dotSize: 7),
      ),
    );
  }
}
