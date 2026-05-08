import 'package:flutter/material.dart';

import '../../../../../user/domain/entities/profile.dart';
import 'dialog_actions_helper.dart';

class CustomMessageDialog extends StatelessWidget {
  CustomMessageDialog({super.key, required this.user});
  final ProfileEntity user;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('رسالة مخصصة'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'عنوان الرسالة',
              hintText: 'مثلاً: عرض خاص',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _messageController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'نص الرسالة',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.send),
          onPressed: () {
            Navigator.pop(context);
            DialogActionsHelper.executeSendMessage(
              context,
              user,
              _titleController.text,
              _messageController.text,
            );
          },
          label: const Text('إرسال'),
        ),
      ],
    );
  }
}
