import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../user/domain/entities/profile.dart';
import '../../controllers/admin_users_provider.dart';

class AddCreditsDialog extends ConsumerStatefulWidget {
  const AddCreditsDialog({super.key, required this.user});
  final ProfileEntity user;

  @override
  ConsumerState<AddCreditsDialog> createState() => _AddCreditsDialogState();
}

class _AddCreditsDialogState extends ConsumerState<AddCreditsDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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

              ref
                  .read(adminUsersControllerProvider.notifier)
                  .addCredits(userId: widget.user.userId, amount: amount);
            }
          },
          child: const Text('تأكيد الشحن'),
        ),
      ],
    );
  }
}
