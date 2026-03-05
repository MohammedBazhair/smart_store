import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../auth/presentation/widgets/custom_phone_field.dart';
import '../controller/store_provider.dart';

void showAddMemberDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) {
      return const AddMemberDialog();
    },
  );
}

class AddMemberDialog extends ConsumerStatefulWidget {
  const AddMemberDialog({super.key});

  @override
  ConsumerState<AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends ConsumerState<AddMemberDialog> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 10,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // العنوان
            const Text(
              'إضافة عضو لمتجرك',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // حقل النص
            Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: CustomPhoneField(_phoneController),
            ),
            const SizedBox(height: 25),

            // الأزرار
            Row(
              spacing: 15,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final isValid =
                          _formKey.currentState?.validate() ?? false;
                      if (!isValid) return;

                      final phone = _phoneController.text;
                      await ref
                          .read(storeControllerProvider.notifier)
                          .addStoreMember(phone);

                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 5,
                    ),
                    child: const Text(
                      'إضافة',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade400),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text(
                      'إلغاء',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
