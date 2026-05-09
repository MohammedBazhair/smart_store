import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../user/domain/entities/profile.dart';
import 'add_credits_dialog.dart';
import 'change_status_dialog.dart';
import 'change_user_info_dialog.dart';
import 'custom_message_dialog.dart';

enum AdminActionType {
  changeUserStatus,
  changeUserInfo,
  addCredits,
  sendMessage,
}

void showAdminActionDialog({
  required BuildContext context,
  required AdminActionType actionType,
  required ProfileEntity user,
}) {
  showDialog(
    context: context,
    builder: (context) => AdminActionGateDialog(
      adminActionType: actionType,
      user: user,
    ),
  );
}

class AdminActionGateDialog extends ConsumerWidget {
  const AdminActionGateDialog({
    super.key,
    required this.adminActionType,
    required this.user,
  });
  final AdminActionType adminActionType;
  final ProfileEntity user;

  @override
  Widget build(BuildContext context, ref) {
    return switch (adminActionType) {
      AdminActionType.changeUserStatus => ChangeStatusDialog(user: user),
      AdminActionType.addCredits => AddCreditsDialog(user: user),
      AdminActionType.sendMessage => CustomMessageDialog(user: user),
      AdminActionType.changeUserInfo => ChangeUserInfoDialog(user: user),
    };
  }
}
