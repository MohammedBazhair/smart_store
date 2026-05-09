import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/extensions/extensions.dart';
import '../../../../../auth/presentation/widgets/custom_fullname_field.dart';
import '../../../../../auth/presentation/widgets/custom_phone_field.dart';
import '../../../../../user/domain/entities/profile.dart';
import '../../controllers/admin_users_provider.dart';

class ChangeUserInfoDialog extends StatefulWidget {
  const ChangeUserInfoDialog({super.key, required this.user});

  final ProfileEntity user;

  @override
  State<ChangeUserInfoDialog> createState() => _ChangeUserInfoDialogState();
}

class _ChangeUserInfoDialogState extends State<ChangeUserInfoDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.username);
    _phoneController = TextEditingController(text: widget.user.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit(WidgetRef ref) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final userId = widget.user.userId;
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();
      await ref
          .read(adminUsersControllerProvider.notifier)
          .updateUserInfo(userId: userId, name: name, phone: phone);

      context.pop();
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
                    'تعديل بيانات المستخدم',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed:context.pop,
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
                  CustomFullNameField(nameController: _nameController),

                    const SizedBox(height: 14),

                 CustomPhoneField(_phoneController),

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
                            onPressed: _isLoading ? null : () => _submit(ref),
                            label: Text(
                              _isLoading ? 'جاري الحفظ...' : 'حفظ التغييرات',
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
