import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../controllers/auth_controller.dart';
import '../controllers/auth_state.dart';
import '../widgets/custom_email_field.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final isValidForm = _formKey.currentState?.validate() ?? false;
    if (!isValidForm) return;
    final email = _emailController.text;

    await ref.read(authProvider.notifier).resetPassword(email);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        appBar: AppBar(title: const Text('استعادة كلمة المرور')),
        body: Form(
          key: _formKey,
          child: Center(
            child: ListView(
              padding: const EdgeInsets.all(24),
              shrinkWrap: true,
              children: [
                const Text(
                  'نسيت كلمة المرور؟',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 24),
                const Text(
                  'لا تقلق، فقط اكتب بريدك الإلكتروني \n وسنرسل لك تعليمات لتغيير كلمة المرور',
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    height: 2,
                  ),
                ),

                const SizedBox(height: 35),

                CustomEmailField(_emailController),

                const SizedBox(height: 24),

                AbsorbPointer(
                  absorbing: ref.watch(authProvider) is AuthLoadingState,
                  child: ElevatedButton(
                    onPressed: _resetPassword,
                    child: const Text('استعادة الباسورد'),
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
