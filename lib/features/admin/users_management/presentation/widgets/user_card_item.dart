import 'package:flutter/material.dart';
import '../../../../user/domain/entities/profile.dart';
import '../../../../user/domain/entities/status_config.dart';
import 'dialogs/admin_action_gate_dialog.dart';

class UserCardItem extends StatelessWidget {
  const UserCardItem({
    super.key,
    required this.user,
  });
  final ProfileEntity user;

  @override
  Widget build(BuildContext context) {
    final statusColor =
        StatusConfig.getStatusConfig(user.accountStatus).primaryColor;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(Icons.person, color: statusColor),
        ),
        title: Text(
          user.username,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('رقم: ${user.phone ?? "غير متوفر"}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            user.accountStatus.name,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        children: [
          const Divider(),
          _ActionTile(
            icon: Icons.security_rounded,
            title: 'حالة الحساب',
            subtitle: 'تعديل الصلاحيات',
            color: Colors.orange,
            actionType: AdminActionType.changeUserStatus,
            user: user,
          ),
          _ActionTile(
            icon: Icons.account_balance_wallet_rounded,
            title: 'الرصيد',
            subtitle: 'الحالي: ${user.credits}',
            color: Colors.green,
            actionType: AdminActionType.addCredits,
            user: user,
          ),
          _ActionTile(
            icon: Icons.phone,
            title: 'تواصل مباشر',
            subtitle: 'إرسال رسالة مخصصة',
            color: Colors.blue,
            actionType: AdminActionType.sendMessage,
            user: user,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.actionType,
    required this.user,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final AdminActionType actionType;
  final ProfileEntity user;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: color,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => showAdminActionDialog(
        context: context,
        actionType: actionType,
        user: user,
      ),
    );
  }
}
