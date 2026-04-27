import 'package:flutter/material.dart';

import '../../../../core/shared/presentation/theme/app_theme.dart';

class BackupProgressCircle extends StatelessWidget {
  const BackupProgressCircle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return TweenAnimationBuilder(
      tween: Tween(begin: 0.0, end: 100.0),
      duration: const Duration(seconds: 5),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: screenSize.width * 0.6,
              height: screenSize.width * 0.6,
              child: CircularProgressIndicator(
                value: value / 100,
                strokeWidth: 8,
                strokeCap: StrokeCap.round,
                backgroundColor: const Color(0x339E9E9E),
                color: AppTheme.primaryColor,
              ),
            ),
            Column(
              spacing: 10,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${value.toInt()}%',
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                child!,
              ],
            ),
          ],
        );
      },
      child: Text(
        'جاري التجهيز...',
        style: TextTheme.of(context).bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
      ),
    );
  }
}
