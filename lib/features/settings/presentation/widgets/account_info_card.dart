import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../../core/shared/presentation/widgets/common/info_row.dart';
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
            InfoRow(
              icon: Icons.person,
              title: 'اسم المستخدم',
              value: profile.username,
            ),
            const Divider(),
            InfoRow(
              icon: Icons.email,
              title: 'البريد الإلكتروني',
              value: email ?? '',
            ),
            const Divider(),
            InfoRow(
              icon: Icons.account_balance_wallet,
              title: 'الرصيد',
              value: '${profile.credits}',
            ),
            const Divider(),
            InfoRow(
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
