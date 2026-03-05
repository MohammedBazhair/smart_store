import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../../core/shared/presentation/widgets/common/field_label.dart';
import '../../../../core/shared/presentation/widgets/common/loading_widget.dart';
import '../../handle_auth_listeners.dart';
import '../controllers/auth_controller.dart';
import '../controllers/auth_state.dart';
import '../widgets/custom_email_field.dart';
import '../widgets/custom_password_field.dart';
import '../widgets/sign_google_button.dart';
import 'reset_password_screen.dart';
import 'sign_up_screen.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    listenAuthStates();
  }

  void listenAuthStates() {
    ref.listenManual(authControllerProvider, (previous, next) async {
      await handlgeAuthListener(
        context: context,
        previous: previous,
        next: next,
        ref: ref,
      );
    });
  }

  void onSubmit() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) return;
    TextInput.finishAutofillContext();
    final password = _passwordController.text;
    final email = _emailController.text;

    await ref
        .read(authControllerProvider.notifier)
        .loginWithEmail(email: email, password: password);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
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
              ),
              const Text(
                'أهلا بعودتك!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'سجل دخولك إلى حسابك',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 50),
              Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const FieldLabel(text: 'البريد الإلكتروني'),
        
                      const SizedBox(height: 8),
        
                      CustomEmailField(_emailController),
        
                      const SizedBox(height: 25),
        
                      const FieldLabel(text: 'كلمة المرور'),
        
                      const SizedBox(height: 8),
        
                      CustomPasswordField(
                        controller: _passwordController,
                        hintText: 'أدخل كلمة المرور',
                        onSubmit: onSubmit,
                        textInputAction: TextInputAction.done,
                      ),
        
                      const SizedBox(height: 25),
        
                      // نسيت كلمة المرور
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: 'هل نسيت كلمة المرور؟',
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              context.pushTo(const ResetPasswordScreen());
                            },
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
        
                      // زر تسجيل الدخول
                      Consumer(
                        builder: (context, ref, child) {
                          final isLoading = ref.watch(authControllerProvider)
                              is AuthLoadingState;
                          return AbsorbPointer(
                            absorbing: isLoading,
                            child: ElevatedButton(
                              onPressed: onSubmit,
                              child: isLoading
                                  ? const LoadingWidget()
                                  : const Text('تسجيل الدخول'),
                            ),
                          );
                        },
                      ),
        
                      const SizedBox(height: 15),
        
                      AbsorbPointer(
                        absorbing: ref.watch(authControllerProvider)
                            is AuthLoadingState,
                        child: const SignGoogleButton(),
                      ),
        
                      const SizedBox(height: 25),
        
                      // الانتقال إلى التسجيل
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: 'ليس لديك حساب؟ ',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            const TextSpan(text: '  '),
                            TextSpan(
                              text: 'سجل الآن',
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  context.pushReplacementTo(
                                    const SignUpScreen(),
                                  );
                                },
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
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
    );
  }
}
