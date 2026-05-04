import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../user/domain/entities/role.dart';
import '../../domain/entities/store_member.dart';
import '../controller/store_provider.dart';

class MemberItem extends ConsumerWidget {
  const MemberItem({super.key, required this.member});
  final StoreMember member;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOwner = member.role == Role.storeOwner;

    return Dismissible(
      key: ObjectKey(member.primaryKey),
      confirmDismiss: (_) async => !isOwner,
      direction: isOwner ? DismissDirection.none : DismissDirection.endToStart,
      onDismissed: (_) {
        ref
            .read(storeControllerProvider.notifier)
            .removeStoreMember(member.primaryKey.memberPhone);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withOpacity(.15),
          child: Text(
            member.primaryKey.memberPhone.substring(0, 2),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
        title: Text(member.primaryKey.memberPhone),
        subtitle: Text(member.role.label),
        trailing: isOwner
            ? const Icon(Icons.workspace_premium, color: Colors.amber)
            : null,
      ),
    );
  }
}
