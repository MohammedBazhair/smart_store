import 'package:flutter/material.dart';

import '../../../../../core/extensions/extensions.dart';

class CloseButton extends StatelessWidget {
  const CloseButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: context.pop,
      child: const Text('إغلاق'),
    );
  }
}
