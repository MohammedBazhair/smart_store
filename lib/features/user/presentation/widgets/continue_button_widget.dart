import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/providers/core_providers.dart';
import '../../../../core/utils/send_messages_utils.dart';
import '../../../products/presentation/screens/init_screen.dart';
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
          if (canContinue) {
            final prefs = ref.read(localCacheServiceProvider);
            await prefs.setBool(key: 'has_shown_account_status', value: true);

            await context.pushReplacementTo(const InitScreen());
            return;
          }

          try {
            await sendPushNotification(
              playerIds: ['776793111'],
              title: 'تم تفعيل حسابك',
              message: 'مرحباً، تم تفعيل حسابك في تطبيق Smart Store. يمكنك الآن الوصول إلى جميع الميزات والاستمتاع بتجربتك معنا.',
            );

            // await UrlUtils.sendWhatsApp(
            //   phone: '967776793111',
            //   message:
            //       'مرحباً، أود الاستفسار عن حالة حسابي في تطبيق Smart Store.',
            // );
          } catch (e) {
            context.showSnakbar(
              'حدثت مشكلة اثناء ارسال رسالة للدعم الفني',
              type: SnackBarType.error,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: config.primaryColor,
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
