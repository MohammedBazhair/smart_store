import 'package:flutter/material.dart';
import '../../../../user/domain/entities/profile.dart';

class UserCardItem extends StatelessWidget {
  const UserCardItem({
    super.key,
    required this.user,
    required this.onChangeStatus,
    required this.onAddCredits,
    required this.onSendMessage,
  });
  final ProfileEntity user;
  final VoidCallback onChangeStatus;
  final VoidCallback onAddCredits;
  final VoidCallback onSendMessage;

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(user.accountStatus.name);

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
          _buildActionTile(
            Icons.security_rounded,
            'حالة الحساب',
            'تعديل الصلاحيات',
            Colors.orange,
            onChangeStatus,
          ),
          _buildActionTile(
            Icons.account_balance_wallet_rounded,
            'الرصيد',
            'الحالي: ${user.credits}',
            Colors.green,
            onAddCredits,
          ),
          _buildActionTile(
            Icons.phone,
            'تواصل مباشر',
            'إرسال رسالة مخصصة',
            Colors.blue,
            onSendMessage,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    IconData icon,
    String title,
    String sub,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
      onTap: onTap,
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'frozen':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }
}
