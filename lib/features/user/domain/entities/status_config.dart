import 'package:flutter/material.dart';

import '../../../../core/shared/presentation/theme/app_theme.dart';
import 'account_status.dart';

class StatusConfig {
  StatusConfig({
    required this.title,
    required this.description,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
    required this.features,
  });

  factory StatusConfig.getStatusConfig(AccountStatus status) {
    switch (status) {
      case AccountStatus.active:
        return StatusConfig(
          title: 'حساب نشط',
          description:
              'حسابك نشط بالكامل! يمكنك الآن الاستفادة من جميع ميزات التطبيق والوصول إلى كافة الخدمات المتاحة.',
          icon: Icons.verified_user_rounded,
          primaryColor: AppTheme.successColor,
          secondaryColor: const Color(0xFF10B981),
          features: [
            'الوصول الكامل لجميع الميزات',
            'إمكانية إضافة وإدارة المنتجات',
            'تلقي الإشعارات والتنبيهات',
            'الدعم الفني على مدار الساعة',
          ],
        );
      case AccountStatus.frozen:
        return StatusConfig(
          title: 'حساب مجمد مؤقتاً',
          description:
              'حسابك مجمد بشكل مؤقت. يمكنك تسجيل الدخول ولكن بعض الميزات قد تكون محدودة. يرجى التواصل مع الدعم الفني لمزيد من المعلومات.',
          icon: Icons.pause_circle_outline_rounded,
          primaryColor: AppTheme.warningColor,
          secondaryColor: const Color(0xFFF59E0B),
          features: [
            'إمكانية تسجيل الدخول والتصفح',
            'عرض البيانات والمعلومات',
            'بعض الميزات محدودة مؤقتاً',
            'التواصل مع الدعم الفني متاح',
          ],
        );
      case AccountStatus.pending:
        return StatusConfig(
          title: 'في انتظار التفعيل',
          description:
              'حسابك قيد المراجعة حالياً. سيتم تفعيل حسابك بالكامل بعد إتمام عملية التحقق. قد يستغرق ذلك بضع دقائق.',
          icon: Icons.hourglass_empty_rounded,
          primaryColor: AppTheme.secondaryColor,
          secondaryColor: const Color(0xFF818CF8),
          features: [
            'الحساب قيد المراجعة',
            'سيتم التفعيل قريباً',
            'يمكنك تصفح التطبيق',
            'ستصلك إشعارات عند التفعيل',
          ],
        );
    }
  }

  final String title;
  final String description;
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;
  final List<String> features;
}
