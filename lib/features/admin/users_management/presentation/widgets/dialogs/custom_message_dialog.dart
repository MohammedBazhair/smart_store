import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../user/domain/entities/profile.dart';
import '../../../domain/entities/notification_payload.dart';
import '../../controllers/admin_users_provider.dart';

class CustomMessageDialog extends StatefulWidget {
  const CustomMessageDialog({super.key, required this.user});

  final ProfileEntity user;

  @override
  State<CustomMessageDialog> createState() => _CustomMessageDialogState();
}

class _CustomMessageDialogState extends State<CustomMessageDialog> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'العنوان مطلوب';
    }
    if (value.length < 3) {
      return 'العنوان قصير جدًا';
    }
    if (value.length > 50) {
      return 'العنوان طويل جدًا';
    }
    return null;
  }

  String? _validateMessage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'نص الرسالة مطلوب';
    }
    if (value.length < 10) {
      return 'الرسالة قصيرة جدًا';
    }
    if (value.length > 500) {
      return 'الرسالة طويلة جدًا';
    }
    return null;
  }

  Future<void> _send(WidgetRef ref) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final payloadMsg = NotificationPayload(
        title: _titleController.text.trim(),
        message: _messageController.text.trim(),
      );
      ref.read(adminUsersControllerProvider.notifier).notifyUser(
            phone: widget.user.phone,
            payload: payloadMsg,
          );

      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // HEADER
              Row(
                children: [
                  const Icon(Icons.message_rounded),
                  const SizedBox(width: 8),
                  const Text(
                    'إرسال رسالة مخصصة',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // FORM
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      validator: _validateTitle,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'عنوان الرسالة',
                        hintText: 'مثال: عرض خاص لك 🎉',
                        prefixIcon: Icon(Icons.title),
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _messageController,
                      validator: _validateMessage,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'نص الرسالة',
                        hintText: 'اكتب تفاصيل الرسالة هنا...',
                        alignLabelWithHint: true,
                        prefixIcon: Icon(Icons.edit_note),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // BUTTON
                    Consumer(
                      builder: (context, ref, _) {
                        return SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            icon: _isLoading
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.send),
                            onPressed: _isLoading ? null : () => _send(ref),
                            label: Text(
                              _isLoading ? 'جاري الإرسال...' : 'إرسال الرسالة',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
