import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../user/domain/entities/status_config.dart';
import '../../domain/entities/user_search_result.dart';
import '../providers/admin_stores_provider.dart';

class UserResultsSearchWidget extends ConsumerWidget {
  const UserResultsSearchWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, ref) {
    final searchUsers = ref.watch(
      adminStoresControllerProvider.select((s) => s.resultsUsersSearch),
    );
    final selectedUser = ref.watch(
      adminStoresControllerProvider.select((s) => s.selectedUser),
    );
    final isLoading = ref.watch(
      adminStoresControllerProvider.select((s) => s.isLoading),
    );
    final resultUsers = isLoading ? UserSearchResult.fakeList : searchUsers;

    return SliverList.builder(
      itemCount: resultUsers.length,
      itemBuilder: (context, index) {
        final userResult = resultUsers[index];
        final accountStatusConfig =
            StatusConfig.getStatusConfig(userResult.accountStatus);

        final isSelected = userResult.userId == selectedUser?.userId;
        return Skeletonizer(
          enabled: isLoading,
          child: ListTile(
            selected: isSelected,
            selectedColor: Colors.green[600],
            selectedTileColor: accountStatusConfig.secondaryColor.withAlpha(30),
            title: Text(userResult.userName),
            subtitle: Text(userResult.phone),
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: accountStatusConfig.primaryColor,
              child: Icon(
                accountStatusConfig.icon,
                color: Colors.white,
              ),
            ),
            trailing: isSelected ? const Icon(Icons.check_circle) : null,
            onTap: () => ref
                .read(adminStoresControllerProvider.notifier)
                .selectUser(userResult),
          ),
        );
      },
    );
  }
}
