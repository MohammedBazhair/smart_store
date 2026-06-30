import 'package:flutter/material.dart';
import '../../../../store/domain/entities/store_member.dart';

class MembersExpansionTile extends StatelessWidget {
  const MembersExpansionTile({super.key, required this.members});

  final Set<StoreMember> members;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blueAccent.withAlpha(5),
        child: Icon(Icons.person, color: Colors.blueAccent.withAlpha(200)),
      ),
      title: Text(
        'عدد الأعضاء: ${members.length}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      shape: const RoundedRectangleBorder(),
      children: [
        const Divider(thickness: 0.3),
        ...members.map(
          (member) => ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 4,
            ),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                member.role.isStoreOwner ? Icons.manage_accounts : Icons.person,
                color: Colors.blue,
              ),
            ),
            title: Text(
              member.primaryKey.memberPhone,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              member.role.label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
