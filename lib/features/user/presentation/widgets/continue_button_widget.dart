import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/presentation/widgets/loading/three_dots_loading.dart';
import '../../../../core/shared/providers/core_providers.dart';
import '../../../../core/utils/send_messages_utils.dart';
import '../../../store/presentation/screens/store_selection_screen.dart';
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
    final isLoading = ref.watch(appSyncLoadingProvider);
    return ElevatedButton(
      onPressed: isLoading
          ? null
          : () async {
              if (canContinue) {
                
                  ref.read(appSyncLoadingProvider.notifier).state = true;
                  await ref.refresh(appSyncProvider.future);
                  ref.read(appSyncLoadingProvider.notifier).state = false;
    
                  await context
                      .pushAndRemoveUntilTo(const StoreSelectionScreen());
               
                return;
              }
    
              try {
                await UrlUtils.sendWhatsApp(
                  phone: '967776793111',
                  message:
                      'مرحباً، أود الاستفسار عن حالة حسابي في تطبيق Smart Store.',
                );
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
      child: isLoading
          ? const ThreeDotsLoading(dotSize: 7)
          : Text(
              canContinue ? 'متابعة إلى التطبيق' : 'تواصل مع الادمن',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
            ),
    );
  }
}
