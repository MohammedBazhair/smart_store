import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/log.dart';
import '../../../../../core/shared/providers/ui_providers.dart';
import '../../../../user/domain/entities/account_status.dart';
import '../../data/admin_user_repository.dart';
import 'admin_users_provider.dart';
import 'admin_users_state.dart';

class AdminUsersController extends Notifier<AdminUsersState> {
  AdminUserRepository get _repository => ref.read(adminUserRepositoryProvider);

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
      ref.read(appUiEventProvider.notifier).showError(e.toString());
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
      ref.read(appUiEventProvider.notifier).showSuccess('تم التحديث بنجاح');
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      ref.read(appUiEventProvider.notifier).showError(e.toString());
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
      ref
          .read(appUiEventProvider.notifier)
          .showError('يجب أن يكون الرصيد أكبر من صفر');
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
      ref.read(appUiEventProvider.notifier).showSuccess('تم إضافة الرصيد بنجاح');
    } catch (e, st) {
      Logger.debugLog(error: e, stackTrace: st);
      ref.read(appUiEventProvider.notifier).showError(e.toString());
      state = state.copyWith(
        isLoading: false,
      );
    }
  }
}
