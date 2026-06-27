import '../../../../store/presentation/controller/store_state.dart';

class AdminStoresState {
  AdminStoresState({
    this.storeWithMembers = const {},
    this.isLoading = false,
    this.error,
  });

  final Map<String,StoreWithMembers> storeWithMembers;
  final bool isLoading;
  final String? error;

  AdminStoresState copyWith({
    Map<String,StoreWithMembers>? storeWithMembers,
    bool? isLoading,
    String? error,
  }) {
    return AdminStoresState(
      storeWithMembers: storeWithMembers ?? this.storeWithMembers,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
