import 'package:flutter/material.dart';

import '../../../../errors/result.dart';
import '../../../extensions/extensions.dart';
import '../../../utils/permissions.dart';
import '../theme/app_theme.dart';
import 'auth_gate.dart';

class PermissionDeniedScreen extends StatelessWidget {
  const PermissionDeniedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.notifications_off_rounded,
              size: 80,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 24),
            const Text(
              'تم تعطيل الإشعارات',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'هذا التطبيق يعتمد على الإشعارات للتنبيه بانتهاء الصلاحية.\n'
              'يرجى تفعيل الإشعارات للمتابعة.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                final result = await PermissionsService.requestNotification();

                if (result is SuccessState<bool> && result.data) {
                  // إعادة تشغيل التطبيق
                  await context.pushReplacementTo(const AuthGate());
                }
              },
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
