import 'package:flutter/material.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../auth/presentation/widgets/custom_button.dart';
import '../widgets/current_backup_info.dart';

class BackupSuccessScreen extends StatelessWidget {
  const BackupSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نجحت العملية'),
      ),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(24),
          children: [
            CircleAvatar(
              foregroundColor: Colors.white,
              backgroundColor: AppTheme.primaryColor.withAlpha(150),
              radius: 80,
              child: const Icon(
                Icons.check_rounded,
                size: 100,
              ),
            ),
            const SizedBox(height: 50),
            Text(
              'العملية انتهت بنجاح',
              textAlign: TextAlign.center,
              style: TextTheme.of(context).headlineMedium,
            ),
            const SizedBox(height: 15),
            const Text(
              'بياناتك تم معالجتها بنجاح وصارت آمنة الآن',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 50),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CurrentBackupInfo(),
              ),
            ),
            const SizedBox(height: 50),
            CustomButton(onPressed: context.pop, child: const Text('تم')),
          ],
        ),
      ),
    );
  }
}
