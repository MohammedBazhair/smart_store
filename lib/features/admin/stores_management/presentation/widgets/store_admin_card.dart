import 'package:flutter/material.dart';

import '../../../../../core/extensions/extensions.dart';
import '../../../../store/domain/entities/store.dart';
import '../../../../store/presentation/controller/store_state.dart';
import 'members_expansion_tile.dart';
import 'popup_admin_card.dart';

class StoreAdminCard extends StatelessWidget {
  const StoreAdminCard({
    super.key,
    required this.storeWithMembers,
  });

  final StoreWithMembers storeWithMembers;
  Store get store => storeWithMembers.store;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        clipBehavior: Clip.hardEdge,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Stack(
          children: [
            if (store.id != null)
              Positioned(
                top: -40,
                left: -40,
                child: PopupStoreAdmin(
                  storeId: store.id!,
                ),
              ),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// TOP
                    FractionallySizedBox(
                      widthFactor: 0.75,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                colors: [
                                  theme.primaryColor,
                                  theme.primaryColor.withOpacity(.75),
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.storefront_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  store.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  store.ownerPhone,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// INFO
                    Row(
                      children: [
                        Expanded(
                          child: _InfoTile(
                            title: 'العملة',
                            value: store.currency.label,
                            icon: Icons.payments_rounded,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoTile(
                            title: 'الحالة',
                            value: store.isDeleted ? 'محذوف' : 'نشط',
                            icon: store.isDeleted
                                ? Icons.block_rounded
                                : Icons.verified_rounded,
                            color: store.isDeleted ? Colors.red : Colors.blue,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Divider(
                      color: Colors.grey.shade200,
                    ),

                    const SizedBox(height: 14),

                    /// DATES
                    Row(
                      children: [
                        Expanded(
                          child: _BottomInfo(
                            title: 'تاريخ الإنشاء',
                            value: store.createdAt.formattedDate(),
                          ),
                        ),
                        Expanded(
                          child: _BottomInfo(
                            title: 'آخر تحديث',
                            value: store.updatedAt.formattedDate(),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    MembersExpansionTile(members: storeWithMembers.members),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withOpacity(.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomInfo extends StatelessWidget {
  const _BottomInfo({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
