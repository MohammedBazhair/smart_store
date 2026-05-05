import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../domain/entities/store.dart';
import '../../domain/entities/store_member.dart';
import '../controller/store_provider.dart';

class StoreCard extends ConsumerWidget {
  const StoreCard({
    super.key,
    required this.store,
    required this.owner,
    required this.membersLength,
    required this.onPressed,
  });

  final Store store;
  final StoreMember owner;
  final int membersLength;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, ref) {
    const color = AppTheme.primaryColor;

    final isSelected = ref.watch(
      storeControllerProvider
          .select((s) => s.state.selectedStoreId == store.id),
    );
    final borderRadius = BorderRadius.circular(25);
    return Material(
      shadowColor: const Color(0x42F3F2F2),
      color: Colors.transparent,
      borderRadius: borderRadius,
      elevation: 7,
      child: InkWell(
        borderRadius: borderRadius,
        splashColor: color.withOpacity(0.15),
        highlightColor: color.withOpacity(0.06),
        onTap: onPressed,
        child: Ink(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: borderRadius,
            border: Border.all(
              color: isSelected ? color.withAlpha(150) : Colors.grey.shade200,
              width: .8,
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(.25),
                        color.withOpacity(.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.store_rounded, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        store.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.workspace_premium,
                            size: 16,
                            color: color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            owner.primaryKey.memberPhone,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.date_range,
                            size: 16,
                            color: color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            store.createdAt.formattedDate(),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  verticalDirection: VerticalDirection.up,
                  children: [
                    /// MEMBERS INFO
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.groups, size: 18, color: color),
                        const SizedBox(width: 10),
                        Text(
                          '$membersLength',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: color,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),

                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Text(
                          'محدد',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
