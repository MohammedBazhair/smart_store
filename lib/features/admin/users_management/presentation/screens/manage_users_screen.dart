import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../core/shared/presentation/controllers/app_ui_event_controller.dart';
import '../../../../user/domain/entities/profile.dart';
import '../controllers/admin_users_provider.dart';
import '../widgets/user_card_item.dart';
import '../widgets/user_search_bar.dart';

class ManageUsersScreen extends ConsumerStatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  ConsumerState<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends ConsumerState<ManageUsersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminUsersControllerProvider.notifier).fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    listenToUiEvents(context, ref);

    final usersState = ref.watch(adminUsersControllerProvider);

    final searchState = ref.watch(
      adminUsersSearchControllerProvider,
    );

    final isLoading = usersState.isLoading;

    final usersMap =
        searchState.query.isEmpty ? usersState.users : searchState.results;

    final users = usersMap.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المستخدمين'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Skeletonizer(
          enabled: isLoading,
          child: Column(
            spacing: 24,
            children: [
              const UserSearchBar(),
              Expanded(
                child: _UsersListView(
                  users: isLoading ? ProfileEntity.fakeList : users,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UsersListView extends ConsumerWidget {
  const _UsersListView({
    required this.users,
  });

  final List<ProfileEntity> users;

  @override
  Widget build(BuildContext context, ref) {
    if (users.isEmpty) {
      return const _EmptyState();
    }

    return RefreshIndicator(
      onRefresh: ref.read(adminUsersControllerProvider.notifier).fetchUsers,
      child: ListView.separated(
        itemCount: users.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final user = users[index];

          return UserCardItem(user: user);
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_search_rounded,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'لا يوجد مستخدمين يطابقون بحثك',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
