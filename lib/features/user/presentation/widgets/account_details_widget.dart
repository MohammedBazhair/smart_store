import 'package:flutter/material.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../domain/entities/profile.dart';
import 'detail_row_widget.dart';

class AccountDetailsWidget extends StatelessWidget {
  const AccountDetailsWidget({super.key, required this.profile});

  final ProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.textTertiary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Text(
            'تفاصيل الحساب',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          if (profile.username.isNotEmpty)
            DetailRowWidget(
              icon: Icons.person_outline,
              label: 'اسم المستخدم',
              value: profile.username,
            ),
          if (profile.phone != null)
            DetailRowWidget(
              icon: Icons.phone_outlined,
              label: 'رقم الهاتف',
              value: profile.phone!,
            ),
          
          if (profile.createdAt != null)
            DetailRowWidget(
              icon: Icons.calendar_today_outlined,
              label: 'تاريخ الإنشاء',
              value: profile.createdAt!.formattedDate,
            ),
        ],
      ),
    );
  }
}
