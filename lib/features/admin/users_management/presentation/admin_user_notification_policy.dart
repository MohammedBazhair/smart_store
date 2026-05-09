import '../../../user/domain/entities/account_status.dart';
import '../domain/entities/notification_payload.dart';

class AdminUserNotificationPolicy {
  const AdminUserNotificationPolicy._();

  static NotificationPayload statusChanged(AccountStatus status) {
    return switch (status) {
      AccountStatus.active => const NotificationPayload(
          title: 'تحديث حالة الحساب',
          message:
              'تم تفعيل حسابك بنجاح ويمكنك الآن استخدام جميع الخدمات بدون قيود.',
        ),
      AccountStatus.frozen => const NotificationPayload(
          title: 'تحديث حالة الحساب',
          message:
              'تم تعليق حسابك مؤقتًا. يرجى التواصل مع الدعم لمعرفة التفاصيل.',
        ),
      AccountStatus.pending => const NotificationPayload(
          title: 'حالة الحساب قيد المراجعة',
          message: 'حسابك قيد المراجعة حاليًا وسيتم إعلامك فور اكتمال التحقق.',
        ),
    };
  }


  static NotificationPayload creditsAdded(int amount) {
    return NotificationPayload(
      title: 'تمت إضافة رصيد',
      message:
          'تم إضافة $amount رصيد إلى حسابك. يمكنك استخدامه مباشرة داخل التطبيق.',
    );
  }
}
