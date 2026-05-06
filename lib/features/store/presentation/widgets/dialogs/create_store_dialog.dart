import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../../../core/shared/presentation/widgets/common/loading_widget.dart';
import '../../../../auth/presentation/widgets/custom_button.dart';
import '../../controller/store_provider.dart';
import '../custom_store_name_field.dart';

Future<void> showCreateStoreDialog(
  BuildContext context,
) async {
  await showDialog(
    context: context,
    builder: (context) => const CreateStoreDialog(),
  );
}

class CreateStoreDialog extends ConsumerStatefulWidget {
  const CreateStoreDialog({
    super.key,
  });

  @override
  ConsumerState<CreateStoreDialog> createState() => _CreateStoreDialogState();
}

class _CreateStoreDialogState extends ConsumerState<CreateStoreDialog> {
  final _storeNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _error;
  bool _isLoading = false;

  @override
  void dispose() {
    _storeNameController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    setState(() {
      _error = null;
      _isLoading = true;
    });

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final name = _storeNameController.text.trim();

    final cntroller = ref.read(storeControllerProvider.notifier);

    final serverError = await cntroller.createStore(name);

    if (serverError == null) return context.pop();

    setState(() {
      _error = serverError;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 10,
      backgroundColor: Colors.white,
      child: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // العنوان
              const Text(
                'إنشاء متجر جديد',
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
                child: CustomStoreNameField(
                  controller: _storeNameController,
                  errorText: _error,
                  onSubmitted: _onSubmit,
                ),
              ),
              const SizedBox(height: 25),

              // الأزرار
              Row(
                spacing: 15,
                children: [
                  Expanded(
                    child: CustomButton(
                      onPressed: _isLoading ? null : _onSubmit,
                      buttonStyle: ElevatedButton.styleFrom(
                        elevation: 5,
                      ),
                      child: _isLoading
                          ? const LoadingWidget()
                          : const Text(
                              'إنشاء',
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
      ),
    );
  }
}
