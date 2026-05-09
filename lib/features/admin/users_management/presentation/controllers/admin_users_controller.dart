import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/log.dart';
import '../../../../../core/shared/presentation/controllers/app_ui_event_controller.dart';
import '../../../../../core/shared/providers/ui_providers.dart';
import '../../../../../core/utils/send_messages_utils.dart';
import '../../../../user/domain/entities/account_status.dart';
import '../../data/admin_user_repository.dart';
import '../../domain/entities/notification_payload.dart';
import '../admin_user_notification_policy.dart';
import 'admin_users_provider.dart';
import 'admin_users_state.dart';

class AdminUsersController extends Notifier<AdminUsersState> {
  AdminUserRepository get _repository => ref.read(adminUserRepositoryProvider);
  AppUiEventController get _appUiController =>
      ref.read(appUiEventProvider.notifier);

  @override
  AdminUsersState build() {
    return const AdminUsersState();
  }

  Future<void> fetchUsers() async {
    try {
      state = state.copyWith(
        isLoading: true,
      );

      final users = await _repository.getAllUsers();

      state = state.copyWith(
        isLoading: false,
        users: users,
      );
    } catch (e, st) {
      _appUiController.showError(e.toString());
      state = state.copyWith(
        isLoading: false,
      );
      Logger.debugLog(error: e, stackTrace: st);
    }
  }

  Future<void> updateUserStatus({
    required String userId,
    required AccountStatus status,
  }) async {
    try {
      state = state.copyWith(
        isLoading: true,
      );

      final copiedUsers = {...state.users};

      final profile = copiedUsers[userId];
      if (profile == null) throw Exception();

      final updatedProfile = profile.copyWith(accountStatus: status);

      await _repository.updateUserStatus(updatedProfile);

      copiedUsers.update(
        userId,
        (value) => updatedProfile,
      );

      state = state.copyWith(
        isLoading: false,
        users: copiedUsers,
      );
      _appUiController.showSuccess('تم التحديث بنجاح');

      final payload = AdminUserNotificationPolicy.statusChanged(status);

      notifyUser(
        phone: updatedProfile.phone,
        payload: payload,
      );
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      _appUiController.showError(e.toString());
      state = state.copyWith(
        isLoading: false,
      );
    }
  }

  Future<void> addCredits({
    required String userId,
    required int amount,
  }) async {
    if (amount <= 0) {
      _appUiController.showError('يجب أن يكون الرصيد أكبر من صفر');
      return;
    }
    try {
      state = state.copyWith(
        isLoading: true,
      );

      final updatedProfile = await _repository.addCredits(userId, amount);

      final copiedUsers = {...state.users};
      copiedUsers.update(userId, (value) => updatedProfile);

      state = state.copyWith(
        isLoading: false,
        users: copiedUsers,
      );
      ref
          .read(appUiEventProvider.notifier)
          .showSuccess('تم إضافة الرصيد بنجاح');

      final payload = AdminUserNotificationPolicy.creditsAdded(amount);

      notifyUser(phone: updatedProfile.phone, payload: payload);
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      _appUiController.showError(e.toString());
      state = state.copyWith(
        isLoading: false,
      );
    }
  }

  void notifyUser({
    required String? phone,
    required NotificationPayload payload,
  }) async {
    if (phone?.isEmpty ?? true) {
      _appUiController
          .showError('هاتف المستخدم الذي تريد ارسال له رسالة غير محدد');
      return;
    }

    await sendPushNotification(
      playerIds: [phone!],
      title: payload.title,
      message: payload.message,
    );
  }
}
