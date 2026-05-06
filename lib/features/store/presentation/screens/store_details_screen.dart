import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../auth/presentation/widgets/custom_button.dart';
import '../controller/store_provider.dart';
import '../widgets/dialogs/add_member_dialog.dart';
import '../widgets/store_member_item.dart';
import '../widgets/store_name_inline_edit.dart';

class StoreDetailsScreen extends ConsumerWidget {
  const StoreDetailsScreen({
    super.key,
    required this.storeId,
  });

  final String? storeId;

  @override
  Widget build(BuildContext context, ref) {
    if (storeId == null) return const _StoreNotFoundView();

    final storeWithMembers = ref.watch(
      storeControllerProvider.select((s) => s.state.myStores[storeId]),
    );

    if (storeWithMembers == null) return const _StoreNotFoundView();
    final members = storeWithMembers.members.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل المتجر'),
      ),
      body: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        onDoubleTap: () =>
            ref.read(isEditingStoreNameProvider.notifier).state = false,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'معلومات المتجر',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const _StoreHeader(),
              const SizedBox(height: 40),
              const Text(
                'أعضاء المتجر',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  itemCount: members.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final member = members.elementAt(i);
                    return StoreMemberItem(member: member);
                  },
                ),
              ),
              const SizedBox(height: 10),
              const _AddMemberButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoreHeader extends ConsumerWidget {
  const _StoreHeader();

  String membersCountText(int membersCount) {
    if (membersCount == 0) {
      return 'لا يوجد أعضاء';
    } else if (membersCount == 1) {
      return 'عضو واحد';
    } else if (membersCount == 2) {
      return 'عضوان';
    } else if (membersCount >= 3 && membersCount <= 10) {
      return '$membersCount أعضاء';
    } else {
      return '$membersCount عضو';
    }
  }

  @override
  Widget build(BuildContext context, ref) {
    final members = ref.watch(
      storeControllerProvider
          .select((s) => s.state.selectedStore?.members ?? {}),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 15,
          mainAxisSize: MainAxisSize.min,
          children: [
            const StoreNameInlineEdit(),
            Row(
              spacing: 15,
              children: [
                Text(
                  membersCountText(members.length),
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
                Expanded(
                  child: SizedBox(
                    height: 30,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        final isOwner =
                            members.elementAt(index).role.isStoreOwner;
                        return isOwner
                            ? const Icon(Icons.workspace_premium_rounded)
                            : const Icon(Icons.person);
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddMemberButton extends StatelessWidget {
  const _AddMemberButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.person_add),
      label: const Text('إضافة عضو'),
      onPressed: () => showAddMemberDialog(context),
    );
  }
}

class _StoreNotFoundView extends StatelessWidget {
  const _StoreNotFoundView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('خطأ في البيانات')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.storefront_outlined,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary.withAlpha(200),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'المتجر غير موجود',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'نعتذر، لم نتمكن من العثور على بيانات المتجر المطلوب. قد يكون قد تم حذفه أو أن الرابط غير صحيح.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: 32),
              CustomButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('العودة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
