import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/shared/presentation/widgets/common/bottom_sheet_handle.dart';
import '../../domain/entities/store_member.dart';
import 'add_member_dialog.dart';
import 'member_item.dart';

void showMembersSheet(
  BuildContext context,
  String storeId,
  Set<StoreMember> members,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) {
      return FractionallySizedBox(
        heightFactor: 0.7,
        child: StoreMembersSheet(
          storeId: storeId,
          members: members.toList(),
        ),
      );
    },
  );
}

class StoreMembersSheet extends ConsumerWidget {
  const StoreMembersSheet({
    super.key,
    required this.storeId,
    required this.members,
  });
  final String storeId;
  final List<StoreMember> members;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BottomSheetHandle(),
          const Text(
            'أعضاء المتجر',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: members.length,
              itemBuilder: (_, index) {
                final member = members[index];

                return MemberItem(member: member);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.person_add),
                label: const Text('إضافة عضو'),
                onPressed: () {
                  Navigator.pop(context);
                  showAddMemberDialog(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
