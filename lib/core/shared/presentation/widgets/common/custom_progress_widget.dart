import 'package:flutter/material.dart';

class CustomProgressWidget extends StatelessWidget {
  const CustomProgressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 27,
      width: 27,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
