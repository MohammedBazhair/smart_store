import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../domain/product_expiry_status.dart';

class StatusIcon extends StatelessWidget {
  const StatusIcon(this.status, {super.key});

  final ProductExpiryStatus status;

  @override
  Widget build(BuildContext context) {
    return Skeleton.leaf(
      child: CircleAvatar(
        radius: 22,
        backgroundColor: status.color.withValues(alpha: 0.1),
        child: Icon(status.icon, color: status.color, size: 24),
      ),
    );
  }
}
