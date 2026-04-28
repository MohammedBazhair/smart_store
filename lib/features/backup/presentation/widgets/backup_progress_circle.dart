import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../controllers/progress_controller.dart';

class BackupProgressCircle extends ConsumerWidget {
  const BackupProgressCircle({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: screenSize.width * 0.6,
          height: screenSize.width * 0.6,
          child: Consumer(
            builder: (_, ref, __) {
              final progress =
                  ref.watch(progressControllerProvider.select((s) => s.value));
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return CircularProgressIndicator(
                    value: value,
                    strokeWidth: 8,
                    strokeCap: StrokeCap.round,
                    backgroundColor: const Color(0x339E9E9E),
                    color: AppTheme.primaryColor,
                  );
                },
              );
            },
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Consumer(
              builder: (_, ref, child) {
                final progress = ref.watch(
                  progressControllerProvider.select((s) => s.progressUiText),
                );
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      child!,
                      Text(
                        progress,
                        key: ValueKey(progress),
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: const Text(
                '%',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Consumer(
              builder: (_, ref, __) {
                final uiText = ref.watch(
                  progressControllerProvider.select((s) => s.stage),
                );
                return Text(
                  uiText,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
