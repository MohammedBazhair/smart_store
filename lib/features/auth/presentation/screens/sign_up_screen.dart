import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../../core/shared/presentation/widgets/common/field_label.dart';
import '../../../../core/shared/presentation/widgets/common/loading_widget.dart';
import '../../auth_listeners.dart';
import '../controllers/auth_controller.dart';
import '../controllers/auth_state.dart';
import '../widgets/custom_email_field.dart';
import '../widgets/custom_password_field.dart';
import 'sign_in_screen.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    ref.listenManual(authProvider, (previous, next) async {
      await authListener(
        context: context,
        previous: previous,
        next: next,
        ref: ref,
      );
    });
    super.initState();
  }

  void onSubmit() async {
    final isValid = formKey.currentState?.validate() ?? false;

    if (!isValid) return;

    TextInput.finishAutofillContext();

    await ref.read(authProvider.notifier).signUp(
          email: emailController.text,
          password: passwordController.text,
        );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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
                  height: 35,
                ), // العنوان
                const Text(
                  'إنشاء حساب',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'سجل للحصول على تجربة أفضل في إدارة ملاحظاتك ومزامنتها عبر أجهزتك.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),

                const SizedBox(height: 50),

                Form(
                  key: formKey,
                  child: AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const FieldLabel(text: 'البريد الإلكتروني'),

                        const SizedBox(height: 8),

                        CustomEmailField(emailController),
                        const SizedBox(height: 25),

                        const FieldLabel(text: 'كلمة المرور'),
                        const SizedBox(height: 8),

                        CustomPasswordField(
                          controller: passwordController,
                          hintText: 'أدخل كلمة المرور',
                        ),

                        const SizedBox(height: 25),

                        const FieldLabel(text: 'تأكيد الباسورد'),
                        const SizedBox(height: 8),

                        CustomPasswordField(
                          originalController: passwordController,
                          controller: confirmPasswordController,
                          hintText: 'أعد إدخال كلمة المرور',
                          onSubmit: onSubmit,
                          textInputAction: TextInputAction.done,
                        ),

                        const SizedBox(height: 35),

                        // زر إنشاء الحساب
                        Consumer(
                          builder: (context, ref, child) {
                            final isLoading =
                                ref.watch(authProvider) is AuthLoadingState;
                            return AbsorbPointer(
                              absorbing: isLoading,
                              child: ElevatedButton(
                                onPressed: onSubmit,
                                child: isLoading
                                    ? const LoadingWidget()
                                    : const Text('إنشاء حساب'),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 15),

                        // العودة لتسجيل الدخول
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: 'لديك حساب بالفعل؟',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              const TextSpan(text: '  '),
                              TextSpan(
                                text: 'سجل الدخول',
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    context.pushReplacementTo(
                                      const SignInScreen(),
                                    );
                                  },
                                style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
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
