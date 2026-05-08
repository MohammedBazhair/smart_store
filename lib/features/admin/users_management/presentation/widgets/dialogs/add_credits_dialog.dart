import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../user/domain/entities/profile.dart';
import 'dialog_actions_helper.dart';

class AddCreditsDialog extends StatelessWidget {
  AddCreditsDialog({super.key, required this.ref, required this.user});
  final WidgetRef ref;
  final ProfileEntity user;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.add_card, color: Colors.green),
          SizedBox(width: 10),
          Text('شحن رصيد'),
        ],
      ),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'المبلغ المراد إضافته',
          suffixText: 'ر.ي',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            final amount = int.tryParse(_controller.text);
            if (amount != null && amount > 0) {
              Navigator.pop(context);
              DialogActionsHelper.executeAddCredits(
                context: context,
                ref: ref,
                user: user,
                amount: amount,
              );
            }
          },
          child: const Text('تأكيد الشحن'),
        ),
      ],
    );
  }
}
