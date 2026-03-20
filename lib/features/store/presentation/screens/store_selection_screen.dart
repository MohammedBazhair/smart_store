import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../../core/shared/providers/core_providers.dart';
import '../../../auth/presentation/widgets/sign_out_button.dart';
import '../../../products/presentation/screens/init_screen.dart';
import '../../../user/domain/entities/status_config.dart';
import '../../../user/presentation/widgets/status_icon_widget.dart';
import '../../domain/entities/store.dart';
import '../../domain/entities/store_member.dart';
import '../controller/store_provider.dart';
import '../handle_store_states.dart';
import '../widgets/create_store_dialog.dart';
import '../widgets/members_sheet.dart';

class StoreSelectionScreen extends ConsumerWidget {
  const StoreSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    ref.listen(storeControllerProvider, (_, event) {
      handleStoreStates(event, context);
    });
    final stores = ref.watch(storeControllerProvider).state.myStoresList;

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
        onRefresh: () async {
          await ref.refresh(appSyncProvider.future);
        },
        child: CustomScrollView(
          physics: const NeverScrollableScrollPhysics(),
          slivers: [
            const SliverAppBar(
              toolbarHeight: 60,
              pinned: true,
              floating: true,
              backgroundColor: AppTheme.primaryColor,
              actions: [
                SignOutButton(),
              ],
              title: Text(
                'المتاجر',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SliverVisibility(
              visible: stores.isNotEmpty,
              sliver: const SliverPadding(
                padding: EdgeInsetsGeometry.only(
                  top: 24,
                  left: 24,
                  right: 24,
                ),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.touch_app_outlined,
                        size: 18,
                        color: AppTheme.textSecondary,
                      ),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'اضغط مطولاً على المتجر لإدارة الأعضاء',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            /// STORES GRID
            SliverPadding(
              padding: const EdgeInsetsGeometry.all(24),
              sliver: stores.isEmpty
                  ? const SliverFillRemaining(
                      child: _EmptyStoresView(),
                    )
                  : SliverList.separated(
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
        onTap: () {
          ref.read(storeControllerProvider.notifier).selectStore(store.id!);
          context.pushAndRemoveUntilTo(const InitScreen());
        },
        onLongPress: () {
          showMembersSheet(context, store.id!, members);
        },
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
                            store.createdAt.formattedDate,
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
                          '${members.length}',
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
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: [
          // أيقونة احترافية
          StatusIconWidget(
            config: config,
            onPressed: () => showCreateStoreDialog(context),
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
            child: Consumer(
              builder: (_,  ref, __) {
                return ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
            
                            showCreateStoreDialog(context);
                          },
                          icon: const Icon(Icons.add, size: 20),
                          label: const Text(
                            'إنشاء متجر جديد',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
              },
            ),
          ),
        ],
      ),
    );
  }
}
