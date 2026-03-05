import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../products/presentation/screens/init_screen.dart';
import '../../../user/domain/entities/status_config.dart';
import '../../../user/presentation/widgets/status_icon_widget.dart';
import '../../domain/entities/store.dart';
import '../../domain/entities/store_member.dart';
import '../controller/store_provider.dart';
import '../handle_store_states.dart';
import '../widgets/add_member_dialog.dart';
import '../widgets/create_store_dialog.dart';

class StoreSelectionScreen extends ConsumerWidget {
  const StoreSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    ref.listen(storeControllerProvider, (_, event) {
      handleStoreStates(event, context);
    });

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        elevation: 1,
        onPressed: () => showCreateStoreDialog(context),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        edgeOffset: 100,
        onRefresh: () =>
            ref.read(storeControllerProvider.notifier).loadMyStores(),
        child: CustomScrollView(
          slivers: [
            const SliverAppBar(
              toolbarHeight: 60,
              pinned: true,
              backgroundColor: AppTheme.primaryColor,
              title: Text(
                'المتاجر',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            /// STORES GRID
            SliverPadding(
              padding: const EdgeInsetsGeometry.all(24),
              sliver: SliverFillRemaining(
                child: Consumer(
                  builder: (_, ref, __) {
                    final state = ref.watch(storeControllerProvider).state;
                    final stores = state.myStores.values.toList();

                    return stores.isEmpty
                        ? const _EmptyStoresView()
                        : ListView.separated(
                            itemCount: stores.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 20),
                            itemBuilder: (context, index) {
                              return _StoreCard(
                                store: stores[index].store,
                                owner: stores[index].owner,
                                members: stores[index].members,
                              );
                            },
                          );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreCard extends ConsumerWidget {
  const _StoreCard({
    required this.store,
    required this.owner,
    required this.members,
  });

  final Store store;
  final StoreMember owner;
  final Set<StoreMember> members;

  @override
  Widget build(BuildContext context, ref) {
    const color = AppTheme.primaryColor;

    final isSelected = ref.watch(
      storeControllerProvider
          .select((s) => s.state.selectedStoreId == store.id),
    );

    final membersList = members.toList();

    return GestureDetector(
      onTap: () {
        ref.read(storeControllerProvider.notifier).selectStore(store.id!);
        context.pushAndRemoveUntilTo(const InitScreen());
      },
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFBFEFF) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? color.withOpacity(.25) : Colors.transparent,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            /// HEADER
            Row(
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: color.withOpacity(.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.store, color: color),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      Text(
                        '${owner.role.label}: ${owner.memberPhone}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                /// ADD MEMBER BUTTON
                IconButton(
                  tooltip: 'إضافة عضو',
                  onPressed: () {
                    showAddMemberDialog(context);
                  },
                  icon: const Icon(
                    Icons.person_add_alt_1,
                    color: color,
                  ),
                ),

                Icon(
                  isSelected ? Icons.check_circle : Icons.arrow_forward_ios,
                  size: isSelected ? 28 : 18,
                  color: color,
                ),
              ],
            ),

            const SizedBox(height: 18),

            /// MEMBERS
            Row(
              children: [
                const Icon(
                  Icons.groups,
                  size: 18,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 6),
                const Text(
                  'الأعضاء',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${members.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// MEMBERS AVATARS
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: membersList.length > 6 ? 6 : membersList.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final member = membersList[index];

                  return CircleAvatar(
                    radius: 18,
                    backgroundColor: color.withOpacity(.12),
                    child: Text(
                      member.memberPhone.substring(0, 2),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyStoresView extends StatelessWidget {
  const _EmptyStoresView();

  @override
  Widget build(BuildContext context) {
    final config = StatusConfig(
      icon: Icons.store_mall_directory_sharp,
      primaryColor: AppTheme.primaryColor,
      secondaryColor: AppTheme.primaryColor.withOpacity(0.6),
    );
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // أيقونة احترافية
          StatusIconWidget(
            config: config,
          ),
          const SizedBox(height: 60),

          const Text(
            'لا يوجد لديك متاجر بعد',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'ابدأ بإنشاء متجرك الأول لإدارة منتجاتك ومخزونك بسهولة واحترافية.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 35),

          SizedBox(
            width: 220,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              onPressed: () => showCreateStoreDialog(context),
              icon: const Icon(Icons.add, size: 20),
              label: const Text(
                'إنشاء متجر جديد',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
