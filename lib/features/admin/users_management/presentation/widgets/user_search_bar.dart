import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/shared/presentation/theme/app_theme.dart';
import '../controllers/admin_users_provider.dart';

class UserSearchBar extends ConsumerWidget {
  const UserSearchBar({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) {
          ref
              .read(adminUsersSearchControllerProvider.notifier)
              .onQueryChanged(value);
        },
        decoration: const InputDecoration(
          hintText: 'بحث بالاسم أو رقم الهاتف...',
          prefixIcon: Icon(
            Icons.search,
            color: AppTheme.primaryColor,
          ),
          suffixIcon: _ClearSearchIconButton(),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}

class _ClearSearchIconButton extends ConsumerWidget {
  const _ClearSearchIconButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(adminUsersSearchControllerProvider);

    if (searchState.query.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: IconButton(
        key: const ValueKey('clear'),
        tooltip: 'مسح البحث',
        icon: const Icon(Icons.close),
        onPressed: () {
          ref.read(adminUsersSearchControllerProvider.notifier).clear();
        },
      ),
    );
  }
}
