import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/constants/enums.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/presentation/screen/auth_gate_screen.dart';
import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../../core/shared/presentation/widgets/common/field_label.dart';
import '../../../../core/shared/presentation/widgets/loading/three_dots_loading.dart';
import '../../../../core/shared/providers/core_providers.dart';
import '../../../user/presentation/handle_user_states.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_fullname_field.dart';
import '../widgets/custom_phone_field.dart';
import '../widgets/sign_out_button.dart';
import '../widgets/user_avatar.dart';

final _isLoadingProvider = StateProvider((_) => false);

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

    ref.read(_isLoadingProvider.notifier).state = true;

    TextInput.finishAutofillContext();

    final controller = ref.read(userControllerProvider.notifier);

    final profile = await controller.loadProfile();

    if (!mounted) return;

    if (profile == null) {
      ref.read(_isLoadingProvider.notifier).state = false;

      if (!mounted) return;

      return context.showSnakbar(
        'لم يتم اعداد الحساب بنجاح الرجاء التواصل معنا',
        type: SnackBarType.error,
      );
    }

    final name = _nameController.text.trim();
    final phone = _phoneController.text.replaceAll(' ', '');

    final newProfile = profile.copyWith(username: name, phone: phone);

    await controller.updateProfile(newProfile);

    if (!mounted) return;

    ref.read(_isLoadingProvider.notifier).state = false;
    await context.pushAndRemoveUntilTo(const AuthGate());
  }

  @override
  void initState() {
    super.initState();
    _initFields();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _initFields() {
    final profile = ref.read(userControllerProvider).entity.profile;
    final name = profile.username;
    final phone = profile.phone;

    _nameController.text = name;
    _phoneController.text = phone ?? _phoneController.text;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      userControllerProvider,
      (_, state) => handleUserStates(state, context),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'إعداد الملف الشخصي',
        ),
        actions: const [SignOutButton()],
      ),
      body: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              const Center(
                child: Hero(
                  tag: 'avatar',
                  child: PremiumAvatar(radius: 60),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'البيانات الشخصية',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FieldLabel(text: 'الاسم الكامل'),
                      const SizedBox(height: 10),
                      CustomFullNameField(
                        nameController: _nameController,
                      ),
                      const SizedBox(height: 24),
                      const FieldLabel(text: 'رقم الهاتف'),
                      const SizedBox(height: 10),
                      CustomPhoneField(_phoneController),
                      const SizedBox(height: 40),

                      // زر المتابعة بتصميم عريض وأنيق
                      Consumer(
                        builder: (context, ref, child) {
                          final isLoading = ref.watch(_isLoadingProvider);
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: double.infinity,
                            height: 56,
                            child: CustomButton(
                              onPressed: isLoading ? null : onSubmit,
                              child: isLoading
                                  ? const ThreeDotsLoading(dotSize: 5)
                                  : const Text(
                                      'حفظ ومتابعة',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
