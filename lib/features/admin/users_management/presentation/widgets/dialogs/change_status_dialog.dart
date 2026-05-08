import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../user/domain/entities/account_status.dart';
import '../../../../../user/domain/entities/profile.dart';
import 'dialog_actions_helper.dart';

class ChangeStatusDialog extends StatefulWidget {
  const ChangeStatusDialog({super.key, required this.ref, required this.user});
  final WidgetRef ref;
  final ProfileEntity user;

  @override
  State<ChangeStatusDialog> createState() => _ChangeStatusDialogState();
}

class _ChangeStatusDialogState extends State<ChangeStatusDialog> {
  late AccountStatus selectedStatus;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.user.accountStatus;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('تحديث حالة المستخدم', textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('اختر الحالة الجديدة للحساب:'),
          const SizedBox(height: 15),
          DropdownButtonFormField<AccountStatus>(
            value: selectedStatus,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: AccountStatus.values
                .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                .toList(),
            onChanged: (val) => setState(() => selectedStatus = val!),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () {
            Navigator.pop(context);
            DialogActionsHelper.executeStatusUpdate(
              context: context,
              ref: widget.ref,
              profile: widget.user,
              status: selectedStatus,
            );
          },
          child: const Text('تحديث الآن'),
        ),
      ],
    );
  }
}
