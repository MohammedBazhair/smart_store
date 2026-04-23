import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/shared/presentation/theme/app_theme.dart';

class AlertsEmptyState extends StatelessWidget {
  const AlertsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/notifications.svg',
            semanticsLabel: 'لا توجد تنبيهات',
            width: 200,
          ),
          const SizedBox(height: 16),
          const Text(
            'لا توجد تنبيهات',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            'ليس لديك أي تنبيهات في الوقت الحالي.\n سنقوم بإخطارك عندما يحدث شيء جديد!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
