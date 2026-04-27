import 'package:flutter/material.dart';

import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../widgets/backup_progress_circle.dart';

class BackupLoadingScreen extends StatelessWidget {
  const BackupLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء نسخة احتياطية'),
      ),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'جاري إنشاء النسخة الاحتياطية',
              textAlign: TextAlign.center,
              style: TextTheme.of(context).headlineMedium,
            ),
            const SizedBox(height: 15),
            const Text(
              'جاري تأمين بياناتك وحفظها بشكل آمن.',
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
