import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../shared/presentation/widgets/common/field_label.dart';
import '../../../../shared/presentation/widgets/common/home_button.dart';
import '../../../user/domain/entities/user.dart';
import '../../auth_listeners.dart';
import '../controllers/auth_controller.dart';
import '../controllers/auth_state.dart';
import '../widgets/custom_email_field.dart';
import '../widgets/custom_fullname_field.dart';
import '../widgets/custom_password_field.dart';
import 'sign_in_screen.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  late final ProviderSubscription<AuthState> authSubscription;

  @override
  void initState() {
    authSubscription = ref.listenManual(authProvider, (previous, next) async {
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

    final user = UserEntity(
      username: nameController.text,
      email: emailController.text,
      password: passwordController.text,
    );

    await ref.read(authProvider.notifier).signUp(user);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    authSubscription.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: FocusScope.of(context).unfocus,
      
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                actions: const [HomeButton()],
                actionsPadding: const EdgeInsets.symmetric(horizontal: 12),
      
                automaticallyImplyLeading: false,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
      
                  child: Form(
                    key: formKey,
                    child: AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // العنوان
                          const Text(
                            'إنشاء حساب',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00FFFF),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'سجل للحصول على تجربة أفضل في إدارة ملاحظاتك ومزامنتها عبر أجهزتك.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xB4ACBFB6),
                            ),
                          ),
      
                          const SizedBox(height: 80),
      
                          // الاسم
                          const FieldLabel(text: 'الاسم الكامل'),
                          const SizedBox(height: 8),
                          CustomFullNameField(nameController: nameController),
      
                          const SizedBox(height: 25),
      
                          // البريد
                          const FieldLabel(text: 'البريد الإلكتروني'),
      
                          const SizedBox(height: 8),
      
                          CustomEmailField(emailController),
                          const SizedBox(height: 25),
      
                          // كلمة المرور
                          const FieldLabel(text: 'كلمة المرور'),
                          const SizedBox(height: 8),
      
                          CustomPasswordField(
                            controller: passwordController,
                            hintText: 'أدخل كلمة المرور',
                          ),
      
                          const SizedBox(height: 25),
      
                          // تأكيد كلمة المرور
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
                          AbsorbPointer(
                            absorbing:
                                ref.watch(authProvider) is AuthLoadingState,
                            child: ElevatedButton(
                              onPressed: onSubmit,
                              child: const Text('إنشاء حساب'),
                            ),
                          ),
      
                          const SizedBox(height: 15),
      
                          // العودة لتسجيل الدخول
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text: 'لديك حساب بالفعل؟',
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
                                    color: Color(0xFF00FFFF),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
