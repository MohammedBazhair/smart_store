import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/constants/enums.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/presentation/widgets/common/conditional_builder.dart';
import '../../../../core/shared/presentation/widgets/common/loading_widget.dart';
import '../../../../core/shared/providers/core_providers.dart';
import '../../../../errors/result.dart';

final _isWritingOnField = StateProvider.autoDispose((_) => false);

class ChangePhoneCard extends ConsumerStatefulWidget {
  const ChangePhoneCard({
    super.key,
    this.phoneController,
  });
  final TextEditingController? phoneController;

  @override
  ConsumerState<ChangePhoneCard> createState() => _ChangePhoneCardState();
}

class _ChangePhoneCardState extends ConsumerState<ChangePhoneCard> {
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.watch(userControllerProvider).profile;
      widget.phoneController?.text = profile.phone!;
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _submit() async {
    final phone = widget.phoneController?.text;
    final profile = ref.watch(userControllerProvider).profile;

    if (phone == null || phone.isEmpty) {
      widget.phoneController?.text = profile.phone!;
      return context.showSnakbar(
        'يجب أن يكون هناك رقم هاتف',
        type: SnackBarType.error,
      );
    }

    if (!phone.startsWith('7') || phone.length != 9) {
      widget.phoneController?.text = profile.phone!;
      return context.showSnakbar(
        'أدخل رقم هاتف صحيح',
        type: SnackBarType.error,
      );
    }

    final controller = ref.read(userControllerProvider.notifier);
    final updated = profile.copyWith(phone: phone);
    final result = await controller.updateProfile(updated);

    if (!context.mounted) return;

    if (result is SuccessState<void>) {
      context.showSnakbar('تم تحديث رقم الهاتف', type: SnackBarType.success);
    } else if (result is ErrorState<void>) {
      context.showSnakbar('لم يتم تحديث رقم الهاتف', type: SnackBarType.error);
      widget.phoneController?.text = profile.phone!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'رقم هاتفك',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            Consumer(
              builder: (_, ref, __) {
                final isLoading = ref.watch(_isWritingOnField);

                return TextField(
                  controller: widget.phoneController,
                  decoration: InputDecoration(
                    labelText: 'رقم الهاتف',
                    suffix: ConditionalBuilder(
                      condition: isLoading,
                      builder: (_) => const LoadingWidget(
                        size: 20,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    ref.read(_isWritingOnField.notifier).state = true;
                    _debounceTimer?.cancel();

                    _debounceTimer =
                        Timer(const Duration(milliseconds: 1350), () async {
                      ref.read(_isWritingOnField.notifier).state = false;
                      await _submit();
                    });
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
