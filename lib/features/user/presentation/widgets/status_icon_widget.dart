import 'package:flutter/material.dart';
import '../../domain/entities/status_config.dart';

class StatusIconWidget extends StatelessWidget {
  const StatusIconWidget({super.key, required this.config});

  final StatusConfig config;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            config.primaryColor,
            config.secondaryColor,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: config.primaryColor.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated Rings
          ...List.generate(3, (index) {
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 2000 + (index * 500)),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 1 + (value * 0.3 * (index + 1)),
                  child: Opacity(
                    opacity: 1 - value,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: config.primaryColor.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // Icon
          Icon(
            config.icon,
            size: 80,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
