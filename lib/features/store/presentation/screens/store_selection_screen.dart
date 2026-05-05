import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../../../core/shared/presentation/widgets/common/hint_row.dart';
import '../../../../core/shared/providers/core_providers.dart';
import '../../../auth/presentation/widgets/sign_out_button.dart';
import '../../../products/presentation/screens/init_screen.dart';
import '../../../user/domain/entities/status_config.dart';
import '../../../user/presentation/widgets/status_icon_widget.dart';
import '../controller/store_provider.dart';
import '../handle_store_states.dart';
import '../widgets/create_store_dialog.dart';
import '../widgets/store_card.dart';

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
          await ref
              .read(appSyncControllerProvider.notifier)
              .sync(isManual: true);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                  child: HintRow(
                    message: 'اضغط مطولاً على المتجر لإدارة الأعضاء',
                    iconData: Icons.touch_app_outlined,
                  ),
                ),
              ),
            ),

            /// STORES GRID
            stores.isEmpty
                ? const SliverFillRemaining(
                    child: EmptyStoresView(),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.all(24),
                    sliver: SliverList.separated(
                      itemCount: stores.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 20),
                      itemBuilder: (context, index) {
                        final store = stores[index];
                        return StoreCard(
                          store: store.store,
                          owner: store.owner,
                          membersLength: store.members.length,
                          onPressed: () {
                            ref
                                .read(storeControllerProvider.notifier)
                                .selectStore(store.store.id!);
                            context.pushAndRemoveUntilTo(const InitScreen());
                          },
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

class EmptyStoresView extends StatelessWidget {
  const EmptyStoresView({super.key});

  @override
  Widget build(BuildContext context) {
    final config = StatusConfig(
      icon: Icons.store_mall_directory_sharp,
      primaryColor: AppTheme.primaryColor,
      secondaryColor: AppTheme.primaryColor.withOpacity(0.6),
    );
    return Center(
      child: ListView(
        padding: const EdgeInsets.all(24),
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
              builder: (_, ref, __) {
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
