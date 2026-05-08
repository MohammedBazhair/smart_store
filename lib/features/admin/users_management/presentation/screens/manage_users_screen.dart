import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/admin_users_provider.dart';
import '../widgets/dialogs/add_credits_dialog.dart';
import '../widgets/dialogs/change_status_dialog.dart';
import '../widgets/dialogs/custom_message_dialog.dart';
import '../widgets/user_card_item.dart';
import '../widgets/user_search_bar.dart';

class ManageUsersScreen extends ConsumerStatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  ConsumerState<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends ConsumerState<ManageUsersScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(adminUsersListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // خلفية Premium هادئة
      appBar: AppBar(
        title: const Text(
          'إدارة المستخدمين',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          // شريط البحث المخصص (ملف مستقل)
          UserSearchBar(
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),

          Expanded(
            child: usersAsync.when(
              data: (users) {
                // منطق الفلترة
                final filteredUsers = users.where((user) {
                  final nameMatch =
                      user.username.toLowerCase().contains(_searchQuery);
                  final phoneMatch =
                      user.phone?.contains(_searchQuery) ?? false;
                  return nameMatch || phoneMatch;
                }).toList();

                if (filteredUsers.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];

                    // بطاقة المستخدم المخصصة (ملف مستقل)
                    return UserCardItem(
                      user: user,
                      onChangeStatus: () =>
                          _openDialog(ChangeStatusDialog(ref: ref, user: user)),
                      onAddCredits: () =>
                          _openDialog(AddCreditsDialog(ref: ref, user: user)),
                      onSendMessage: () =>
                          _openDialog(CustomMessageDialog(user: user)),
                    );
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator.adaptive()),
              error: (error, stack) => _buildErrorState(error.toString()),
            ),
          ),
        ],
      ),
    );
  }

  // دالة مساعدة لفتح النوافذ المنبثقة
  void _openDialog(Widget dialog) {
    showDialog(
      context: context,
      builder: (context) => dialog,
    );
  }

  // واجهة عند عدم وجود بيانات
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search_rounded, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'لا يوجد مستخدمين يطابقون بحثك',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // واجهة عند حدوث خطأ
  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            Text(
              'خطأ في تحميل البيانات: $message',
              textAlign: TextAlign.center,
            ),
            TextButton(
              onPressed: () => ref.invalidate(adminUsersListProvider),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
