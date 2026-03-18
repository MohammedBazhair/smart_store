import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../audio/presentation/controller/audio_provider.dart';
import '../controllers/auth_controller.dart';
import '../controllers/auth_state.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_nonce_field.dart';
import '../widgets/custom_password_field.dart';

class ReconfirmPasswordScreen extends ConsumerStatefulWidget {
  const ReconfirmPasswordScreen({super.key, required this.email});
  final String email;

  @override
  ConsumerState<ReconfirmPasswordScreen> createState() =>
      _ReconfirmPasswordScreenState();
}

class _ReconfirmPasswordScreenState
    extends ConsumerState<ReconfirmPasswordScreen> {
  final _nonceController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nonceController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _reconfirmPassword() async {
    await ref.read(audioControllerProvider.notifier).playButtonClick();
    final isValidForm = _formKey.currentState?.validate() ?? false;
    if (!isValidForm) return;
    final newPassword = _passwordController.text;
    final nonce = _nonceController.text;

    await ref.read(authControllerProvider.notifier).changePassword(
          email: widget.email,
          newPassword: newPassword,
          nonce: nonce,
        );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        appBar: AppBar(title: const Text('تغيير كلمة المرور')),
        body: Form(
          key: _formKey,
          child: Center(
            child: ListView(
              padding: const EdgeInsets.all(24),
              shrinkWrap: true,
              children: [
                const Text(
                  'إنشاء كلمة مرور جديدة',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 35),
                CustomNonceField(nonceController: _nonceController),
                const SizedBox(height: 10),
                CustomPasswordField(
                  controller: _passwordController,
                  hintText: 'أدخل كلمة المرور الجديدة',
                ),
                const SizedBox(height: 10),
                CustomPasswordField(
                  controller: _confirmPasswordController,
                  originalController: _passwordController,
                  hintText: 'أعد إدخال كلمة المرور الجديدة',
                ),
                const SizedBox(height: 24),
                AbsorbPointer(
                  absorbing:
                      ref.watch(authControllerProvider) is AuthLoadingState,
                  child: CustomButton(
                    onPressed: _reconfirmPassword,
                    child: const Text('تغيير الباسورد'),
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
