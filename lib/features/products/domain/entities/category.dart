import 'package:equatable/equatable.dart';

class Category extends Equatable {
  const Category({required this.id, required this.name});

  factory Category.fromRemote(Map<String, dynamic> map) {
    return Category(id: map['id'], name: map['name']);
  }

  factory Category.fromLocal(Map<String, dynamic> map) {
    return Category(id: map['category_id'], name: map['category_name']);
  }

  factory Category.undefined() {
    return const Category(id: 1, name: 'غير مصنف');
  }

  final int id;
  final String name;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  List<Object?> get props => [id];
}
