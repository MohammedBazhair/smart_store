import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/presentation/widgets/common/conditional_builder.dart';
import '../../../../shared/presentation/widgets/common/loading_widget.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

class SaveProductButton extends ConsumerWidget {
  const SaveProductButton({
    super.key,
    required this.onPressed,
  });
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, ref) {
    return AbsorbPointer(
      absorbing: ref.read(isLoadingProvider),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shadowColor: const Color(0xBAB2B2B2),
          elevation: 2,
        ),
        child: ConditionalBuilder(
          condition: !ref.watch(isLoadingProvider),
          builder: (_) => const Text('حفظ المنتج'),
          fallback: (context) => const LoadingWidget(),
        ),
      ),
    );
  }
}
