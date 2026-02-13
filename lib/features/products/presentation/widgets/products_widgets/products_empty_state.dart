import 'package:flutter/material.dart';
import '../../../../../core/shared/presentation/theme/app_theme.dart';

class ProductsEmptyState extends StatelessWidget {
  const ProductsEmptyState({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // أيقونة جذابة
            Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: AppTheme.primaryColor.withOpacity(0.7),
            ),
            const SizedBox(height: 20),

            // النص
            Text(
              text,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                    height: 1.8,
                    fontSize: 16,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
