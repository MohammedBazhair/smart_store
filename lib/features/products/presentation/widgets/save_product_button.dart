import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/enums.dart';
import '../../../../shared/presentation/widgets/common/conditional_builder.dart';
import '../../../../shared/presentation/widgets/common/loading_widget.dart';
import '../../../../shared/providers/ui_providers.dart';

class SaveProductButton extends ConsumerWidget {
  const SaveProductButton({
    super.key,
    required this.onPressed,
  });
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, ref) {
    return AbsorbPointer(
      absorbing: ref.read(isLoadingProvider(IsLoading.saveProduct)),
      child: ElevatedButton(
        onPressed: onPressed,
        child: ConditionalBuilder(
          condition: !ref.watch(isLoadingProvider(IsLoading.saveProduct)),
          builder: (_) => const Text('حفظ المنتج'),
          fallback: (context) => const LoadingWidget(),
        ),
      ),
    );
  }
}
