import 'package:flutter/material.dart';

import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../widgets/backup_progress_circle.dart';

class RestoreLoadingScreen extends StatelessWidget {
  const RestoreLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('استعادة نسخة احتياطية'),
      ),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'جاري استعادة النسخة الاحتياطية',
              textAlign: TextAlign.center,
              style: TextTheme.of(context).headlineMedium,
            ),
            const SizedBox(height: 15),
            const Text(
              'جاري استعادة بياناتك. الرجاء عدم إغلاق التطبيق.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 50),
            const BackupProgressCircle(),
          ],
        ),
      ),
    );
  }
}
