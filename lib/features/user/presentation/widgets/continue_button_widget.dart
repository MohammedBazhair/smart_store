import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/shared/providers/repositories_provider.dart';
import '../../domain/entities/status_config.dart';

class ContinueButtonWidget extends ConsumerWidget {
  const ContinueButtonWidget({
    super.key,
    required this.config,
    required this.canContinue,
  });

  final StatusConfig config;
  final bool canContinue;

  @override
  Widget build(BuildContext context, ref) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () async {
          final prefs = ref.read(sharedPreferencesProvider);
          await prefs.setBool('has_shown_account_status', true);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: config.primaryColor ,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          canContinue ? 'متابعة إلى التطبيق' : 'تواصل مع الادمن',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
        ),
      ),
    );
  }
}
