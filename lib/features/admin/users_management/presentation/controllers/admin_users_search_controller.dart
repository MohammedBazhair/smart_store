import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../user/domain/entities/profile.dart';
import 'admin_users_provider.dart';



class AdminUsersSearchController extends Notifier<AdminUsersSearchState> {
  Timer? _debounce;

  @override
  AdminUsersSearchState build() {
    ref.onDispose(() => _debounce?.cancel());
    return const AdminUsersSearchState();
  }

  void onQueryChanged(String value) {
    final query = value.trim().toLowerCase();

    state = state.copyWith(query: query, isSearching: true);

    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      _search(query);
    });
  }

  void _search(String query) {
    final users = ref.read(adminUsersControllerProvider).users;

    final filtered = {
      for (final user in users.values)
        if (_match(user, query)) user.userId: user,
    };

    state = state.copyWith(
      results: filtered,
      isSearching: false,
    );
  }

  bool _match(ProfileEntity user, String query) {
    final name = user.username.toLowerCase();
    final phone = (user.phone ?? '').toLowerCase();

    return name.contains(query) || phone.contains(query);
  }

 void clear() {
    _debounce?.cancel();
    state = const AdminUsersSearchState();
  }
}

class AdminUsersSearchState {
  const AdminUsersSearchState({
    this.query = '',
    this.results = const {},
    this.isSearching = false,
  });

  final String query;
  final Map<String, ProfileEntity> results;
  final bool isSearching;

  AdminUsersSearchState copyWith({
    String? query,
    Map<String, ProfileEntity>? results,
    bool? isSearching,
  }) {
    return AdminUsersSearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isSearching: isSearching ?? this.isSearching,
    );
  }
}
