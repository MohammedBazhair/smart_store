import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../user/domain/entities/get_profile_params.dart';

final profileParamsProvider = StateProvider<GetProfileParams?>((ref) => null);

class PremiumAvatar extends ConsumerWidget {
  const PremiumAvatar({super.key, this.radius = 32});

  final int radius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileParamsProvider);

    final imageUrl = profile?.userMetadata?.avatarUrl;
    final name = profile?.userMetadata?.name ?? profile?.userMetadata?.fullName;
    final email = profile?.userMetadata?.email;
    if (profile == null) {
      return _loadingAvatar();
    }
    final imageSize = radius * 2;

    return Column(
      spacing: 25,
      children: [
        Container(
          clipBehavior: Clip.hardEdge,
          width: imageSize.toDouble(),
          height: imageSize.toDouble(),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: imageUrl != null
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  cacheHeight: imageSize,
                  cacheWidth: imageSize,
                  
                  loadingBuilder: (
                    _,
                    child,
                    loadingProgress,
                  ) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  frameBuilder: (
                    context,
                    child,
                    frame,
                    wasSynchronouslyLoaded,
                  ) {
                    if (wasSynchronouslyLoaded) {
                      return child;
                    }
                    return AnimatedOpacity(
                      opacity: frame == null ? 0 : 1,
                      duration: const Duration(seconds: 1),
                      curve: Curves.easeOut,
                      child: child,
                    );
                  },
                )
              : _fallback(name),
        ),
        if (email != null)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              email,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _fallback(String? name) {
    final letter =
        (name != null && name.isNotEmpty) ? name.trim().substring(0, 3) : '?';

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Color(0xFF667EEA),
            Color(0xFF764BA2),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _loadingAvatar() {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFE0E0E0),
      ),
      child: const Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
