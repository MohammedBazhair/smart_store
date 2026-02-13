import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {

  const CustomButton({super.key, required this.text, required this.onPressed});
  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(onPressed: onPressed, child: Text(text)),
    );
  }
}
