import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../domain/entities/product_expiry_status.dart';

class StatusIcon extends StatelessWidget {
  const StatusIcon(this.status, {super.key});

  final ProductExpiryStatus status;

  @override
  Widget build(BuildContext context) {
    return Skeleton.leaf(
      child: ClipOval(
        child: CircleAvatar(
          radius: 22,
          backgroundColor: status.color,
          child: Icon(
            status.icon,
            color: Colors.white,
            size: 24,
            shadows: [
              Shadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
