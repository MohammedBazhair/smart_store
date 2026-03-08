import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../user/domain/entities/role.dart';
import '../../domain/entities/store_member.dart';
import '../controller/store_provider.dart';
import 'add_member_dialog.dart';

void showMembersSheet(
  BuildContext context,
  String storeId,
  Set<StoreMember> members,
) {
  final membersList = members.toList();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: .6,
        maxChildSize: .9,
        builder: (_, controller) {
          return Column(
            children: [
              /// HANDLE
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 20),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              /// TITLE
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
                  controller: controller,
                  itemCount: membersList.length,
                  itemBuilder: (_, index) {
                    final member = membersList[index];

                    return Consumer(
                      builder: (_, ref, __) {
                        return Dismissible(
                          key: ValueKey(member.memberPhone),
                          confirmDismiss: (direction) async=> member.role != Role.storeOwner,
                          direction: member.role == Role.storeOwner
                              ? DismissDirection.none
                              : DismissDirection.endToStart,
                          onDismissed: (_) {
                            ref
                                .read(storeControllerProvider.notifier)
                                .removeStoreMember(member.memberPhone);
                          },
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: Colors.red,
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  AppTheme.primaryColor.withOpacity(.15),
                              child: Text(
                                member.memberPhone.substring(0, 2),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                            title: Text(member.memberPhone),
                            subtitle: Text(member.role.label),
                            trailing: member.role.label == 'مالك'
                                ? const Icon(
                                    Icons.workspace_premium,
                                    color: Colors.amber,
                                  )
                                : null,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              /// ADD MEMBER BUTTON
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
          );
        },
      );
    },
  );
}
