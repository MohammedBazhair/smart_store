import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../user/domain/entities/profile.dart';
import '../../data/admin_user_repository.dart';

final adminUserRepositoryProvider = Provider<AdminUserRepository>((ref) {
  return AdminUserRepository(Supabase.instance.client);
});

final adminUsersListProvider = FutureProvider<List<ProfileEntity>>((ref) async {
  final repo = ref.read(adminUserRepositoryProvider);
  return repo.getAllUsers();
});
