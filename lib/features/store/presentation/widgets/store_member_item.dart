import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../user/domain/entities/role.dart';
import '../../domain/entities/store_member.dart';
import '../controller/store_provider.dart';

class StoreMemberItem extends ConsumerWidget {
  const StoreMemberItem({super.key, required this.member});
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
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            radius: 20,
            child: Text(
              member.primaryKey.memberPhone.substring(0, 2),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            member.primaryKey.memberPhone,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            member.role.label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          trailing: isOwner
              ? const IconButton(
                  onPressed: null,
                  icon: Icon(
                    Icons.workspace_premium,
                    color: AppTheme.primaryColor,
                  ),
                )
              : IconButton(
                  icon: const Icon(
                    Icons.delete_forever,
                    color: AppTheme.errorColor,
                  ),
                  onPressed: () {
                    ref
                        .read(storeControllerProvider.notifier)
                        .removeStoreMember(member.primaryKey.memberPhone);
                  },
                ),
        ),
      ),
    );
  }
}
