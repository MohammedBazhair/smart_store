// ignore_for_file: public_member_api_docs, sort_constructors_first
import '../../../../store/presentation/controller/store_state.dart';
import '../../domain/entities/user_search_result.dart';

class AdminStoresState {
  AdminStoresState({
    this.storeWithMembers = const {},
    this.isLoading = false,
    this.error,
    this.resultsUsersSearch = const [],
    this.selectedUser,
  });

  final Map<String, StoreWithMembers> storeWithMembers;
  final List<UserSearchResult> resultsUsersSearch;
  final UserSearchResult? selectedUser;
  final bool isLoading;
  final String? error;

  AdminStoresState copyWith({
    Map<String, StoreWithMembers>? storeWithMembers,
    List<UserSearchResult>? resultsUsersSearch,
    UserSearchResult? selectedUser,
    bool? isLoading,
    String? error,
  }) {
    return AdminStoresState(
      storeWithMembers: storeWithMembers ?? this.storeWithMembers,
      resultsUsersSearch: resultsUsersSearch ?? this.resultsUsersSearch,
      selectedUser: selectedUser ?? this.selectedUser,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
