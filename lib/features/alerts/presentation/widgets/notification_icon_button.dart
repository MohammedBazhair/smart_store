import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/extensions.dart';
import '../controllers/alert_provider.dart';
import '../screens/alerts_screen.dart';

class NotificationIconButton extends StatelessWidget {
  const NotificationIconButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: () {
            context.pushTo(
              const AlertsScreen(
                alertsScreenType: AlertsScreenType.all,
              ),
            );
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Align(child: Icon(Icons.notifications_rounded)),
              Consumer(
                builder: (_, ref, __) {
                  final count = ref.watch(
                    alertsControllerProvider.select((s) => s.allAlerts.length),
                  );
                  if (count == 0) return const SizedBox.shrink();
                  return Positioned(
                    right: 6,
                    top: 6,
                    child: CircleAvatar(
                      backgroundColor: Colors.red.shade400,
                      radius: 11,
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            count > 99 ? '99+' : '$count',
                            textDirection: TextDirection.ltr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
