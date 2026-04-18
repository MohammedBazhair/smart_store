import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../../core/shared/providers/core_providers.dart';
import '../../../auth/presentation/widgets/sign_out_button.dart';

class AccountInfoCard extends ConsumerWidget {
  const AccountInfoCard({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final profile = ref.watch(userControllerProvider).entity.profile;
    final email = ref.read(userControllerProvider.notifier).currentUser?.email;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'معلومات الحساب',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SignOutButton(
                  color: AppTheme.primaryColor,
                ),
              ],
            ),
            const SizedBox(height: 30),
            _InfoRow(
              icon: Icons.person,
              title: 'اسم المستخدم',
              value: profile.username,
            ),
            const Divider(),
            _InfoRow(
              icon: Icons.email,
              title: 'البريد الإلكتروني',
              value: email ?? '',
            ),
            const Divider(),
            _InfoRow(
              icon: Icons.account_balance_wallet,
              title: 'الرصيد',
              value: '${profile.credits}',
            ),
            const Divider(),
            _InfoRow(
              icon: Icons.verified_user,
              title: 'حالة الحساب',
              value: profile.accountStatus.label,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        spacing: 10,
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
