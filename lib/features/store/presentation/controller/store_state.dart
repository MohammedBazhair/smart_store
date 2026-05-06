import '../../../user/domain/entities/role.dart';
import '../../domain/entities/store.dart';
import '../../domain/entities/store_member.dart';

class StoreWithMembers {
  StoreWithMembers({required this.store, required this.members});

  final Store store;
  final Set<StoreMember> members;

  StoreMember get owner => members.firstWhere((m) => m.role == Role.storeOwner);

  StoreWithMembers copyWith({
    Store? store,
    Set<StoreMember>? members,
  }) {
    return StoreWithMembers(
      store: store ?? this.store,
      members: members ?? this.members,
    );
  }
}

class StoreState {
  const StoreState({
    this.myStores = const {},
    this.selectedStoreId,
    this.isInitialized = false,
  });

  final Map<String, StoreWithMembers> myStores;
  final String? selectedStoreId;
  final bool isInitialized;

  List<StoreWithMembers> get myStoresList => myStores.values.toList();
  StoreWithMembers? get selectedStore => myStores[selectedStoreId];
  bool get isSelectedStore => selectedStoreId!= null;

  StoreState copyWith({
    Map<String, StoreWithMembers>? myStores,
    Object? selectedStoreId = _noValue,
    bool? isInitialized,
  }) {
    return StoreState(
      myStores: myStores ?? this.myStores,
      selectedStoreId:selectedStoreId==_noValue?this.selectedStoreId : selectedStoreId as String?,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  static const _noValue = Object();
}

sealed class StoreEventState {
  const StoreEventState({required this.state});
  final StoreState state;
}

class InitialStoreEvent extends StoreEventState {
  const InitialStoreEvent({super.state = const StoreState()});
}

class LoadinMyStoresEvent extends StoreEventState {
  const LoadinMyStoresEvent({required super.state});
}

class LoadMyStoresEvent extends StoreEventState {
  const LoadMyStoresEvent({required super.state});
}

class CreateStoreEvent extends StoreEventState {
  const CreateStoreEvent({required super.state, required this.storeName});
  final String storeName;
}

class UpdateStoreEvent extends StoreEventState {
  const UpdateStoreEvent({required super.state, required this.storeName});
  final String storeName;
}

class UpdateingStoreEvent extends StoreEventState {
  const UpdateingStoreEvent({required super.state});
}

class SelectStoreEvent extends StoreEventState {
  const SelectStoreEvent({required super.state});
}

class UnSelectStoreEvent extends StoreEventState {
  const UnSelectStoreEvent({required super.state});
}

class AddStoreMemberEvent extends StoreEventState {
  const AddStoreMemberEvent({required super.state, required this.member});
  final StoreMember member;
}

class AddingStoreEvent extends StoreEventState {
  const AddingStoreEvent({required super.state});
}

class RemoveStoreMemberEvent extends StoreEventState {
  const RemoveStoreMemberEvent({
    required super.state,
  });
}

class ErrorStoreEvent extends StoreEventState {
  const ErrorStoreEvent({required super.state, required this.error});
  final String error;
}
