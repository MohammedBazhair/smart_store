import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../../core/shared/presentation/widgets/common/field_label.dart';
import '../../../../core/shared/presentation/widgets/common/loading_widget.dart';
import '../../../../core/shared/providers/core_providers.dart';
import '../../../user/presentation/controllers/user_state.dart';
import '../widgets/custom_fullname_field.dart';
import '../widgets/custom_phone_field.dart';

class MoreInfoScreen extends ConsumerStatefulWidget {
  const MoreInfoScreen({super.key});

  @override
  ConsumerState<MoreInfoScreen> createState() => _MoreInfoScreenState();
}

class _MoreInfoScreenState extends ConsumerState<MoreInfoScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void onSubmit() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) return;
    TextInput.finishAutofillContext();

    final controller = ref.read(userControllerProvider.notifier);
    final profile = await controller.loadProfile();

    if (profile == null) {
      return context.showSnakbar(
        'لم يتم اعداد الحساب بنجاح الرجاء التواصل معنا',
        type: SnackBarType.error,
      );
    }

    final name = _nameController.text;
    final phone = _phoneController.text;

    final newProfile = profile.copyWith(username: name, phone: phone);
    await controller.updateProfile(newProfile);
    // await context.pushReplacementTo(const DashboardScreen());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: SafeArea(
          child: Center(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'المتجر الذكي',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(
                  height: 60,
                ),
                const Text(
                  'أكمل بياناتك!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'أدخل اسمك ورقم هاتفك لإكمال عملية التسجيل',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 70),
                Form(
                  key: _formKey,
                  child: AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const FieldLabel(text: 'الاسم الكامل'),
                        const SizedBox(height: 8),
                        CustomFullNameField(nameController: _nameController),
                        const SizedBox(height: 25),
                        const FieldLabel(text: 'رقم الهاتف'),
                        const SizedBox(height: 8),
                        CustomPhoneField(_phoneController),
                        const SizedBox(height: 25),
                        Consumer(
                          builder: (context, ref, child) {
                            final isLoading = ref.watch(userControllerProvider)
                                is UserLoadingProfileState;
                            return AbsorbPointer(
                              absorbing: isLoading,
                              child: ElevatedButton(
                                onPressed: onSubmit,
                                child: isLoading
                                    ? const LoadingWidget()
                                    : const Text('التالي'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
