import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../../core/shared/providers/core_providers.dart';
import '../../domain/entities/store_member.dart';
import '../controller/store_provider.dart';
import 'dialogs/member_confirmaation_delete_dialog.dart';

class StoreMemberItem extends ConsumerWidget {
  const StoreMemberItem({super.key, required this.member});
  final StoreMember member;

  bool get isOwner => member.role.isStoreOwner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final yourPhone =
        ref.watch(userControllerProvider.select((s) => s.entity.profile.phone));
    final isYou = member.primaryKey.memberPhone == yourPhone;
    final primaryColor = isYou ? AppTheme.primaryColor : AppTheme.textPrimary;

    return Dismissible(
      key: ObjectKey(member.primaryKey),
      confirmDismiss: (_) async {
        final isConfirmed = await showDeleteMemberConfirmDialog(context);
        if (isConfirmed != true) return false;

        final isRemoved = await ref
            .read(storeControllerProvider.notifier)
            .removeStoreMember(member.primaryKey.memberPhone);
        return isRemoved;
      },
      direction: isOwner ? DismissDirection.none : DismissDirection.horizontal,
      onDismissed: (_) {},
      background: const DismissibleBackground(isLeft: false),
      secondaryBackground: const DismissibleBackground(isLeft: true),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            radius: 20,
            backgroundColor: primaryColor,
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  isYou ? 'أنت' : member.primaryKey.memberPhone.substring(0, 2),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          title: Text(
            member.primaryKey.memberPhone,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
          subtitle: Text(
            member.role.label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: isYou ? FontWeight.bold : null,
            ),
          ),
          trailing: Icon(
            isOwner ? Icons.workspace_premium : Icons.person_rounded,
            color: primaryColor,
          ),
        ),
      ),
    );
  }
}

class DismissibleBackground extends StatelessWidget {
  const DismissibleBackground({
    super.key,
    required this.isLeft,
  });
  final bool isLeft;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.errorColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.delete,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}
