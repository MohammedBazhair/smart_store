import 'package:flutter/material.dart';

import '../../../../../features/auth/presentation/widgets/custom_button.dart';
import '../../../../extensions/extensions.dart';
import '../../theme/app_theme.dart';
import '../loading/three_dots_loading.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  const DeleteConfirmationDialog({
    super.key,
    required this.title,
    required this.description,
    required this.cancelButtonText,
    required this.confirmButtonText,
    required this.onConfirmPressed,
    this.onCancelPressed,
    this.descriptionAlign = TextAlign.start,
    this.isLoading = false,
  });

  final String title;
  final String description;
  final TextAlign descriptionAlign;
  final String cancelButtonText;
  final String confirmButtonText;
  final VoidCallback? onCancelPressed;
  final VoidCallback onConfirmPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: const EdgeInsets.all(24),
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width,
      ),
      insetPadding: const EdgeInsets.all(30),
      title: Container(
        width: 82,
        height: 82,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.errorColor.withValues(alpha: 0.08),
          border: Border.all(
            color: AppTheme.errorColor.withValues(alpha: 0.15),
            width: 1.2,
          ),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          size: 40,
          color: AppTheme.errorColor,
        ),
      ),
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          description,
          textAlign: descriptionAlign,
          style: TextStyle(
            fontSize: 14,
            height: 1.8,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          spacing: 15,
          children: [
            Expanded(
              child: CustomButton(
                onPressed: isLoading ? null : onConfirmPressed,
                buttonStyle: ElevatedButton.styleFrom(
                  elevation: 5,
                  backgroundColor: Colors.red.shade400,
                  shadowColor: const Color.fromARGB(110, 255, 136, 134),
                ),
                child: isLoading
                    ? const ThreeDotsLoading(dotSize: 5)
                    : Text(
                        confirmButtonText,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: onCancelPressed ?? context.pop,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade400),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text(
                  cancelButtonText,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
