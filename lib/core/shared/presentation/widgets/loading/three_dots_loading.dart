import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class ThreeDotsLoading extends StatefulWidget {
  const ThreeDotsLoading({
    super.key,
    this.dotColor = AppTheme.primaryColor,
    this.dotSize = 10.0,
  });

  final Color dotColor;
  final double dotSize;

  @override
  State<ThreeDotsLoading> createState() => _ThreeDotsLoadingState();
}

class _ThreeDotsLoadingState extends State<ThreeDotsLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: widget.dotSize * 0.5,
      children: List.generate(3, (index) {
        final double start = index * 0.2;
        final double end = start + 0.6;

        // حركة النقاط صعود وهبوط
        final Animation<double> moveAnim = TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(begin: 0.0, end: -8.0)
                .chain(CurveTween(curve: Curves.easeInOutSine)),
            weight: 50,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: -8.0, end: 0.0)
                .chain(CurveTween(curve: Curves.easeInOutSine)),
            weight: 50,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(start, end),
          ),
        );

        // تأثير الشفافية
        final Animation<double> opacityAnim = TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(begin: 0.3, end: 1.0),
            weight: 50,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.0, end: 0.3),
            weight: 50,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(start, end),
          ),
        );

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: opacityAnim.value,
              child: Transform.translate(
                offset: Offset(0, moveAnim.value),
                child: child,
              ),
            );
          },
          child: Container(
            width: widget.dotSize,
            height: widget.dotSize,
            decoration: BoxDecoration(
              color: widget.dotColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.dotColor.withOpacity(0.25),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
