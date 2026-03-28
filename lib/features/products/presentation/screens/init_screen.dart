import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/presentation/screen/dashboard_screen.dart';
import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../auth/presentation/widgets/custom_button.dart';
import '../../../store/presentation/controller/store_provider.dart';
import '../controllers/download_provider.dart';
import '../controllers/product_provider.dart';

class InitScreen extends ConsumerWidget {
  const InitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(initDataFromNetProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          if (previous is AsyncData) return;
          Future(() async {
            await ref.read(storeControllerProvider.notifier).loadMyStores();
            await ref.read(productControllerProvider.notifier).initialize();
            if (!context.mounted) return;
            await context.pushAndRemoveUntilTo(const DashboardScreen());
          });
        },
      );
    });

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const _AnimatedBackground(),
            ref.watch(initDataFromNetProvider).when(
                  data: (_) => const _LoadingContent(),
                  error: (_, __) => _ErrorContent(
                    onRetry: () => ref.refresh(initDataFromNetProvider),
                  ),
                  loading: () => const _LoadingContent(),
                ),
          ],
        ),
      ),
    );
  }
}

/// -----------------
/// BACKGROUND WITH SOFT LIGHT SHAPES
/// -----------------
class _AnimatedBackground extends StatefulWidget {
  const _AnimatedBackground();

  @override
  State<_AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<_AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _rand = Random();
  final int _numCircles = 6;

  late List<double> _positionsX;
  late List<double> _positionsY;

  @override
  void initState() {
    super.initState();
    _positionsX = List.generate(_numCircles, (_) => _rand.nextDouble());
    _positionsY = List.generate(_numCircles, (_) => _rand.nextDouble());

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFFFFF), Color(0xFFF7FAFC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: CustomPaint(
            size: size,
            painter: _CirclePainter(
              positionsX: _positionsX,
              positionsY: _positionsY,
              animationValue: _controller.value,
            ),
          ),
        );
      },
    );
  }
}

class _CirclePainter extends CustomPainter {
  _CirclePainter({
    required this.positionsX,
    required this.positionsY,
    required this.animationValue,
  });
  final List<double> positionsX;
  final List<double> positionsY;
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < positionsX.length; i++) {
      final x = positionsX[i] * size.width;
      final y =
          (positionsY[i] + sin(animationValue * pi * 2) * 0.1) * size.height;
      paint.color = Colors.blueGrey.withOpacity(0.03 + i * 0.02);
      canvas.drawCircle(Offset(x, y), 80 + i * 15, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CirclePainter oldDelegate) => true;
}

/// -----------------
/// LOADING CONTENT
/// -----------------
class _LoadingContent extends StatelessWidget {
  const _LoadingContent();

  @override
  Widget build(BuildContext context) {
    const primary = AppTheme.primaryColor; // soft blue

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0.95, end: 1.05),
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOut,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 25,
                        spreadRadius: 3,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.shopping_cart_rounded,
                    size: 60,
                    color: primary,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 40),
          const Text(
            'جارٍ التحميل...',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'نقوم بمزامنة بيانات منتجاتك',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 50),
          SizedBox(
            width: 180,
            child: LinearProgressIndicator(
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation(primary),
              minHeight: 3.5,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorContent extends StatelessWidget {
  const _ErrorContent({
    this.onRetry,
  });
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    const primary = AppTheme.primaryColor; // نفس اللون المستخدم في التصميم

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // أيقونة خطأ احترافية
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.1),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: Colors.redAccent,
            ),
          ),

          const SizedBox(height: 30),

          // عنوان الخطأ
          const Text(
            'فشل التحميل',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2C3E50),
            ),
          ),

          const SizedBox(height: 10),

          // رسالة الخطأ
          Text(
            'حدث خطأ أثناء مزامنة بيانات منتجاتك.\nيرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 40),

          // زر إعادة المحاولة
          CustomButton(
            onPressed: onRetry,
            buttonStyle: ElevatedButton.styleFrom(
              backgroundColor: primary,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
            ),
            child: const Text(
              'إعادة المحاولة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
