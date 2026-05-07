import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/utils/send_messages_utils.dart';
import '../../../../user/domain/entities/account_status.dart';
import '../../../../user/domain/entities/profile.dart';
import '../providers/admin_users_provider.dart';

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
      appBar: AppBar(
        title: const Text('إدارة المستخدمين'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'بحث بالرقم أو الاسم',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: usersAsync.when(
              data: (users) {
                final filteredUsers = users.where((user) {
                  return user.username.toLowerCase().contains(_searchQuery) ||
                      (user.phone?.contains(_searchQuery) ?? false);
                }).toList();

                if (filteredUsers.isEmpty) {
                  return const Center(child: Text('لا يوجد مستخدمين.'));
                }

                return ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ExpansionTile(
                        title: Text(user.username),
                        subtitle: Text('${user.phone ?? "لا يوجد رقم"} - ${user.accountStatus.name}'),
                        children: [
                          ListTile(
                            leading: const Icon(Icons.security),
                            title: const Text('تغيير حالة الحساب'),
                            onTap: () => _showChangeStatusDialog(context, user),
                          ),
                          ListTile(
                            leading: const Icon(Icons.monetization_on),
                            title: const Text('إضافة رصيد'),
                            subtitle: Text('الرصيد الحالي: ${user.credits}'),
                            onTap: () => _showAddCreditsDialog(context, user),
                          ),
                          ListTile(
                            leading: const Icon(Icons.message),
                            title: const Text('إرسال رسالة يدوية'),
                            onTap: () => _showCustomMessageDialog(context, user),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('خطأ: $error')),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showChangeStatusDialog(BuildContext context, ProfileEntity user) async {
    String selectedStatus = user.accountStatus.name;
    final statuses = AccountStatus.values.map((e) => e.name).toList();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('تغيير حالة الحساب'),
              content: DropdownButton<String>(
                value: selectedStatus,
                isExpanded: true,
                items: statuses.map((status) {
                  return DropdownMenuItem(value: status, child: Text(status));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setStateDialog(() => selectedStatus = val);
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    try {
                      await ref.read(adminUserRepositoryProvider).updateUserStatus(user.userId, selectedStatus);
                      ref.invalidate(adminUsersListProvider);
                      
                      // إرسال رسالة حسب الحالة
                      String message = '';
                      if (selectedStatus == 'active') {
                        message = 'مرحباً ${user.username}، تم تفعيل حسابك بنجاح!';
                      } else if (selectedStatus == 'frozen') {
                        message = 'مرحباً ${user.username}، تم تجميد حسابك مؤقتاً.';
                      }

                      if (message.isNotEmpty) {
                        // استخدام الهاتف في الواتساب أو الإشعار
                        if (user.phone != null) {
                          await UrlUtils.sendWhatsApp(phone: user.phone!, message: message);
                        } else {
                          await sendPushNotification(playerIds: [user.userId], title: 'تحديث حالة الحساب', message: message);
                        }
                      }
                      
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تغيير الحالة بنجاح')));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
                    }
                  },
                  child: const Text('حفظ'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showAddCreditsDialog(BuildContext context, ProfileEntity user) async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('إضافة رصيد'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'قيمة الرصيد للإضافة'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = int.tryParse(controller.text);
                if (amount == null || amount <= 0) return;

                Navigator.pop(context);
                try {
                  await ref.read(adminUserRepositoryProvider).addCredits(user.userId, user.credits, amount);
                  ref.invalidate(adminUsersListProvider);

                  final String message = 'تمت إضافة رصيد بقيمة $amount لحسابك. رصيدك الحالي هو ${user.credits + amount}.';
                  
                  if (user.phone != null) {
                    await UrlUtils.sendWhatsApp(phone: user.phone!, message: message);
                  } else {
                    await sendPushNotification(playerIds: [user.userId], title: 'إضافة رصيد', message: message);
                  }

                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت الإضافة بنجاح')));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
                }
              },
              child: const Text('إضافة'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showCustomMessageDialog(BuildContext context, ProfileEntity user) async {
    final titleController = TextEditingController();
    final messageController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('إرسال رسالة مخصصة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'العنوان'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(labelText: 'نص الرسالة'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text;
                final message = messageController.text;

                if (title.isEmpty || message.isEmpty) return;

                Navigator.pop(context);
                try {
                  if (user.phone != null) {
                    await UrlUtils.sendWhatsApp(phone: user.phone!, message: '[$title]\n$message');
                  } else {
                    await sendPushNotification(playerIds: [user.userId], title: title, message: message);
                  }

                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الإرسال بنجاح')));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
                }
              },
              child: const Text('إرسال'),
            ),
          ],
        );
      },
    );
  }
}
