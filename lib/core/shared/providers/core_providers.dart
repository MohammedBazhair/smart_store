import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../../../features/auth/presentation/controllers/auth_controller.dart';
import '../../../../features/user/data/datasources/user_local_data_source.dart';
import '../../../../features/user/data/datasources/user_remote_data_source.dart';
import '../../../../features/user/data/repositories/user_repository_impl.dart';
import '../../../../features/user/presentation/controllers/user_controller.dart';
import '../../../../features/user/presentation/controllers/user_state.dart';
import '../../../features/store/presentation/controller/store_provider.dart';
import '../../../features/user/domain/entities/role.dart';
import '../../database/local/cache_service.dart';
import '../../database/local/local_database_service.dart';
import '../../database/remote/remote_database_service.dart';
import '../../network/connectivity_service.dart';
import '../../network/network_clinet.dart';
import '../datasources/sync_local_data_source.dart';
import '../domain/services/permission_service.dart';
import '../presentation/controllers/sync_controller.dart';
import 'repositories_provider.dart';

final databaseProvider =
    Provider<Database>((ref) => throw UnimplementedError());

final networkProvider = Provider((_) {
  return ConnectivityServiceImpl(Connectivity());
});

final supabaseProvider = Provider((ref) {
  return Supabase.instance;
});

final supabaseAuthProvider = Provider((ref) {
  final auth = ref.read(supabaseProvider).client.auth;
  return auth;
});

final httpClinetProvider = Provider((ref) {
  return http.Client();
});

final networkCilientProvider = Provider((ref) {
  final clinet = ref.read(httpClinetProvider);

  return NetworkClientImpl(clinet);
});

final authRemoteDataSourceProvider = Provider((ref) {
  final auth = ref.read(supabaseAuthProvider);
  final userRemote = ref.read(userRemoteDataSourceProvider);
  return AuthRemoteDataSourceImpl(auth, userRemote);
});

final userLocalDataSourceProvider = Provider((ref) {
  final localCache = ref.read(localCacheServiceProvider);
  final localDatabase = ref.read(localDatabaseServiceProvider);
  final _sync = ref.read(syncLocalDataSourceProvider);

  return UserLocalDataSourceImpl(localDatabase, localCache, _sync);
});

final userRepositoryProvider = Provider((ref) {
  final auth = ref.read(supabaseAuthProvider);
  final userRemoteDataSource = ref.read(userRemoteDataSourceProvider);
  final userLocalDataSource = ref.read(userLocalDataSourceProvider);
  final _sync = ref.read(syncLocalDataSourceProvider);
  final _connection = ref.read(networkProvider);

  return UserRepositoryImpl(
    userRemoteDataSource,
    userLocalDataSource,
    auth,
    _sync,
    _connection,
  );
});

final remoteDatabaseServiceProvider = Provider((ref) {
  final supabaseClinet = ref.read(supabaseProvider).client;
  return RemoteDatabaseServiceImpl(supabaseClinet);
});

final localDatabaseServiceProvider = Provider((ref) {
  final supabaseClinet = ref.read(databaseProvider);
  return LocalDatabaseServiceImpl(supabaseClinet);
});

final syncLocalDataSourceProvider = Provider((ref) {
  final _db = ref.read(localDatabaseServiceProvider);
  return SyncLocalDataSourceImpl(_db);
});

final localCacheServiceProvider = Provider((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return LocalCacheServiceImpl(prefs);
});

final userRemoteDataSourceProvider = Provider((ref) {
  final remoteDatabaseService = ref.read(remoteDatabaseServiceProvider);
  final localCacheService = ref.read(localCacheServiceProvider);
  return UserRemoteDataSourceImpl(
    remoteDatabaseService,
    localCacheService,
  );
});


final userControllerProvider = NotifierProvider<UserController, UserState>(
  () {
    return UserController();
  },
);

final authRepositoryProvider = Provider((ref) {
  final remoteAuth = ref.read(authRemoteDataSourceProvider);
  final network = ref.read(networkProvider);
  final localCacheService = ref.read(localCacheServiceProvider);
  return AuthRepositoryImpl(remoteAuth, network, localCacheService);
});

final authProvider = Provider((ref) {
  final authRepo = ref.read(authRepositoryProvider);
  return AuthController(authRepo);
});

final tokenRefreshProvider = Provider((ref) {
  final network = ref.watch(networkProvider);
  final supabase = ref.watch(supabaseAuthProvider);
  // استمع لتغييرات الاتصال
  final subscription = network.listenToConnectionChanges((status) async {
    if (await network.hasConnection()) {
      try {
        // جدد التوكن فقط عند الاتصال الأول
        final session = supabase.currentSession;
        if (session == null || session.isExpired) {
          await supabase.refreshSession();
        }
      } catch (e) {
        debugPrint('Failed to refresh token: $e');
      }
    }
  });

  ref.onDispose(subscription.cancel);
});

final permissionServiceProvider = Provider((ref) {
  final accountStatus = ref.watch(userControllerProvider).profile.accountStatus;

  ref.watch(storeControllerProvider);
  final member = ref.read(storeControllerProvider.notifier).meAsCurrentMember;
  final role = member?.role ?? Role.guest;

  return PermissionService(role: role, accountStatus: accountStatus);
});

final appSyncControllerProvider = NotifierProvider<AppSyncController, bool>(() {
  return AppSyncController();
});
