import '../../../../core/constants/enums.dart';

class Store {
  Store({
     this.id,
    required this.ownerId,
    required this.name,
    required this.currency,
    required this.createdAt,
    required this.updatedAt,
  });
  
  final String? id;
  final String  ownerId;
  final String name;
  final Currency currency;
  final DateTime createdAt;
  final DateTime updatedAt;
}
