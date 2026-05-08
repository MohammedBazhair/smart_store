import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/constants/enums.dart';
import '../../../../../../core/constants/log.dart';
import '../../../../../../core/extensions/extensions.dart';
import '../../../../../../core/utils/send_messages_utils.dart';
import '../../../../../user/domain/entities/account_status.dart';
import '../../../../../user/domain/entities/profile.dart';
import '../../controllers/admin_users_provider.dart';

class DialogActionsHelper {
  static String _updateStatusMessage(AccountStatus status) {
    return switch (status) {
      AccountStatus.active => 'تم تفعيل حسابك!',
      AccountStatus.frozen => 'تم تجميد حسابك.',
      AccountStatus.pending => 'جاري تفعيل الحساب'
    };
  }

  static void executeStatusUpdate({
    required BuildContext context,
    required WidgetRef ref,
    required ProfileEntity profile,
    required AccountStatus status,
  }) async {
    await ref
        .read(adminUsersControllerProvider.notifier)
        .updateUserStatus(userId: profile.userId, status: status);
    ref.invalidate(adminUsersListProvider);

    final msg = _updateStatusMessage(status);
    await _notifyUser(
      msg: msg,
      title: 'تحديث الحساب',
      phone: profile.phone ?? '',
    );
  }

  static void executeAddCredits({
    required BuildContext context,
    required WidgetRef ref,
    required ProfileEntity user,
    required int amount,
  }) async {
    try {
      await ref
          .read(adminUserRepositoryProvider)
          .addCredits(user.userId, amount);
      ref.invalidate(adminUsersListProvider);
      await _notifyUser(
        phone: user.phone ?? '',
        title: 'شحن رصيد',
        msg: 'تم إضافة $amount رصيد لحسابك.',
      );
      context.showSnakbar('تم الشحن بنجاح', type: SnackBarType.success);
      Logger.debugLog(message: 'تم الشحن بنجاح $amount');
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      context.showSnakbar('خطأ: $e', type: SnackBarType.error);
    }
  }

  static void executeSendMessage(
    BuildContext context,
    ProfileEntity user,
    String title,
    String message,
  ) async {
    if (title.isEmpty || message.isEmpty) return;
    try {
      await _notifyUser(phone: user.phone ?? '', title: title, msg: message);
      context.showSnakbar('تم الإرسال', type: SnackBarType.success);
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      context.showSnakbar('فشل الإرسال', type: SnackBarType.error);
    }
  }

  static Future<void> _notifyUser({
    required String phone,
    required String title,
    required String msg,
  }) async {
    await sendPushNotification(
      playerIds: [phone],
      title: title,
      message: msg,
    );
  }
}
