import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../domain/entities/store_member.dart';
import '../controller/store_state.dart';
import '../widgets/add_member_dialog.dart';
import '../widgets/store_member_item.dart';
import '../widgets/store_name_inline_edit.dart';

class StoreDetailsScreen extends ConsumerWidget {
  const StoreDetailsScreen({
    super.key,
    required this.storeWithMembers,
  });

  final StoreWithMembers storeWithMembers;

  Set<StoreMember> get members => storeWithMembers.members;

  @override
  Widget build(BuildContext context, ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل المتجر'),
      ),
      body: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        onDoubleTap: () =>
            ref.read(isEditingStoreNameProvider.notifier).state = false,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'معلومات المتجر',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              _StoreHeader(
                membersCount: members.length,
              ),

              const SizedBox(height: 20),
              const SizedBox(height: 20),
              const Text(
                'أعضاء المتجر',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: ListView.separated(
                  itemCount: members.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final member = members.elementAt(i);
                    return StoreMemberItem(member: member);
                  },
                ),
              ),

              const SizedBox(height: 10),

              const _AddMemberButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoreHeader extends StatelessWidget {
  const _StoreHeader({
    required this.membersCount,
  });

  final int membersCount;

  String get membersCountText {
    if (membersCount == 0) {
      return 'لا يوجد أعضاء';
    } else if (membersCount == 1) {
      return 'عضو واحد';
    } else if (membersCount == 2) {
      return 'عضوان';
    } else if (membersCount >= 3 && membersCount <= 10) {
      return '$membersCount أعضاء';
    } else {
      return '$membersCount عضو';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 15,
          children: [
            const StoreNameInlineEdit(),
            Text(
              membersCountText,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddMemberButton extends StatelessWidget {
  const _AddMemberButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.person_add),
      label: const Text('إضافة عضو'),
      onPressed: () => showAddMemberDialog(context),
    );
  }
}
