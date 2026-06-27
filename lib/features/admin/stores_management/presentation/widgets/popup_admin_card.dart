import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/store_action_type.dart';
import '../providers/admin_stores_provider.dart';
import 'add_member_dialog.dart';
import 'store_delete_confirmation_dialog.dart';

class PopupStoreAdmin extends ConsumerWidget {
  const PopupStoreAdmin({
    super.key,
    required this.storeId,
  });
  final String storeId;

  @override
  Widget build(BuildContext context, ref) {
    final controller = ref.read(adminStoresControllerProvider.notifier);

    return PopupMenuButton<StoreActionType>(
      color: Colors.white,
      elevation: 8,
      iconColor: Colors.black87,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      onSelected: (action) async {
        switch (action) {
          case StoreActionType.addMembers:
            await showAddMemberDialog(context, storeId);
          case StoreActionType.deleteStore:
            final canDeleted = await showDeleteStoreDialog(context);
            if (canDeleted) await controller.deleteStore(storeId);
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: StoreActionType.addMembers,
          child: Row(
            children: [
              Icon(Icons.person),
              SizedBox(width: 10),
              Text('إضافة أعضاء'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: StoreActionType.deleteStore,
          child: Row(
            children: [
              Icon(Icons.delete_rounded),
              SizedBox(width: 10),
              Text('حذف المتجر'),
            ],
          ),
        ),
      ],
    );
  }
}
