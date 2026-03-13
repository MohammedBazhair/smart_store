import 'package:flutter/material.dart';

import '../../domain/entities/status_config.dart';

class StatusIconWidget extends StatefulWidget {
  const StatusIconWidget({
    super.key,
    required this.config,
    this.isRepeated = true,
    this.onPressed,
  });
  final StatusConfig config;
  final bool isRepeated;
  final VoidCallback? onPressed;

  @override
  State<StatusIconWidget> createState() => _StatusIconWidgetState();
}

class _StatusIconWidgetState extends State<StatusIconWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    if (widget.isRepeated) _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [widget.config.primaryColor, widget.config.secondaryColor],
          ),
          boxShadow: [
            BoxShadow(
              color: widget.config.primaryColor.withOpacity(0.3),
              blurRadius: 30,
              spreadRadius: 5,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // حلقات متحركة
            for (int i = 0; i < 3; i++)
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final double value = (_controller.value + i * 0.3) % 1.0;
                  return Transform.scale(
                    scale: 1 + (value * 0.2 * (i + 1)),
                    child: Opacity(
                      opacity: 1 - value,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: widget.config.primaryColor.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

            // الأيقونة في المنتصف
            Icon(
              widget.config.icon,
              size: 80,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
