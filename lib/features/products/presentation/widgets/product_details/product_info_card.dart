import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../domain/entities/product_details.dart';
import '../../controllers/product_provider.dart';
import '../../screens/upsert_product_screen.dart';

class BaseProductInfoCard extends ConsumerWidget {
  const BaseProductInfoCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.detailsType,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final ProductDetailsType detailsType;
  final Color iconColor;

  @override
  Widget build(BuildContext context, ref) {
    return Card(
      child: ListTile(
        onTap: () {
          final product = ref.read(currentProductProvider);
          context.pushTo(
            UpsertProductScreen(
              product: product.value,
              detailsType: detailsType,
              isEditing: true,
            ),
          );
        },
        title: Row(
          spacing: 8,
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 18,
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsetsDirectional.only(start: 2, top: 5),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              height: 1.8,
            ),
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      ),
    );
  }
}

class ProductInfoCard extends ConsumerWidget {
  const ProductInfoCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.detailsType,
    required this.iconColor,
    this.subtitleMaxLines = 1,
  });

  final IconData icon;
  final String label;
  final String value;
  final ProductDetailsType? detailsType;
  final Color iconColor;
  final int? subtitleMaxLines;

  @override
  Widget build(BuildContext context, ref) {
    return Card(
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        onTap: () {
          final product = ref.read(currentProductProvider);

          context.pushTo(
            UpsertProductScreen(
              product: product.value,
              detailsType: detailsType,
              isEditing: true,
            ),
          );
        },
        title: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: iconColor.withOpacity(0.08),
              child: Icon(
                icon,
                color: iconColor,
                size: 18,
              ),
            ),
            Text(
              label,
              style:
                  const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
          ],
        ),
        subtitle: Text(
          value,
          maxLines: subtitleMaxLines,
          style:  TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            height: 1.8,
            overflow:subtitleMaxLines == null ? null : TextOverflow.ellipsis,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }
}
