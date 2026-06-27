import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../../../core/shared/presentation/widgets/common/loading_widget.dart';
import '../../../../auth/presentation/widgets/custom_button.dart';
import '../../../../auth/presentation/widgets/custom_phone_field.dart';
import '../../../../store/data/models/store_member_key.dart';
import '../../../../user/domain/entities/role.dart';
import '../providers/admin_stores_provider.dart';
import 'role_segmented_button.dart';

Future<void> showAddMemberDialog(BuildContext context, String storeId) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return AddMemberDialog(storeId: storeId);
    },
  );
}

class AddMemberDialog extends ConsumerStatefulWidget {
  const AddMemberDialog({super.key, required this.storeId});
  final String storeId;
  @override
  ConsumerState<AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends ConsumerState<AddMemberDialog> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  Role _memberRole = Role.worker;
  String? _serverError;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _phoneController.dispose();

    super.dispose();
  }

  Future<void> submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() {
      _isLoading = true;
    });

    final memberKey = StoreMemberKey(
      storeId: widget.storeId,
      memberPhone: _phoneController.text.replaceAll(' ', ''),
    );

    final error =
        await ref.read(adminStoresControllerProvider.notifier).addMemberToStore(
              memberKey: memberKey,
              role: _memberRole,
            );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (error == null) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      _serverError = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // العنوان
          const Text(
            'إضافة عضو',
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
            child: CustomPhoneField(
              _phoneController,
              validator: (_) => _serverError,
              errorMaxLines: 2,
              onChanged: (_) {
                if (_serverError == null) return;
                setState(() => _serverError = null);
              },
            ),
          ),
          const SizedBox(height: 25),
          RoleSegmentedButton(
            role: _memberRole,
            onChanged: (value) => setState(() => _memberRole = value),
          ),
          const SizedBox(height: 25),

          // الأزرار
          Row(
            spacing: 15,
            children: [
              Expanded(
                child: CustomButton(
                  onPressed: _isLoading ? null : submit,
                  buttonStyle: ElevatedButton.styleFrom(
                    elevation: 5,
                  ),
                  child: _isLoading
                      ? const LoadingWidget()
                      : const Text(
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
    );
  }
}
