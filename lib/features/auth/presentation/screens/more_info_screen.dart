import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../../core/shared/presentation/widgets/common/field_label.dart';
import '../../../../core/shared/presentation/widgets/loading/three_dots_loading.dart';
import '../../../../core/shared/providers/core_providers.dart';
import '../../../user/presentation/controllers/user_state.dart';
import '../../../user/presentation/screens/account_status_screen.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_fullname_field.dart';
import '../widgets/custom_phone_field.dart';

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

    if (profile == null) {
      ref.read(_isLoadingProvider.notifier).state = false;

      return context.showSnakbar(
        'لم يتم اعداد الحساب بنجاح الرجاء التواصل معنا',
        type: SnackBarType.error,
      );
    }

    final name = _nameController.text;
    final phone = _phoneController.text;

    final newProfile = profile.copyWith(username: name, phone: phone);
    await controller.updateProfile(newProfile);

    ref.read(_isLoadingProvider.notifier).state = false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(userControllerProvider, (_, state) {
      switch (state) {
        case UserInitialState():
        case UserLoadingProfileState():
        case UserLoadedProfileState():
        case UserUpdatedProfileState():
          break;

        case UserErrorState(:final message):
          context.showSnakbar(message, type: SnackBarType.error);
        case UserMoreInfoProfileState(:final profile):
          context.pushReplacementTo(AccountStatusScreen(profile: profile,));
      }
    });
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
                            final isLoading =
                                ref.watch(_isLoadingProvider.notifier).state;
                            return CustomButton(
                              onPressed:isLoading? null: onSubmit,
                              child: isLoading
                                  ? const ThreeDotsLoading()
                                  : const Text('التالي'),
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
