import '../../../user/domain/entities/role.dart';
import '../../domain/entities/store.dart';
import '../../domain/entities/store_member.dart';

class StoreWithMembers {
  StoreWithMembers({required this.store, required this.members});

  final Store store;
  final Set<StoreMember> members;

  StoreMember get owner => members.firstWhere((m) => m.role == Role.storeOwner);
}

class StoreState {
  const StoreState({
    this.myStores = const {},
    this.selectedStoreId,
  });

  final Map<String, StoreWithMembers> myStores;
  final String? selectedStoreId;

  List<StoreWithMembers> get myStoresList => myStores.values.toList();
  StoreWithMembers? get selectedStore => myStores[selectedStoreId];


  StoreState copyWith({
    Map<String, StoreWithMembers>? myStores,
    String? selectedStoreId,
  }) {
    return StoreState(
      myStores: myStores ?? this.myStores,
      selectedStoreId: selectedStoreId ?? this.selectedStoreId,
    );
  }
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

class SelectStoreEvent extends StoreEventState {
  const SelectStoreEvent({required super.state});
}

class AddStoreMemberEvent extends StoreEventState {
  const AddStoreMemberEvent({required super.state, required this.member});
  final StoreMember member;
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
