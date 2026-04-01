import 'package:equatable/equatable.dart';

class Category extends Equatable {
  const Category({required this.id, required this.name});

  factory Category.fromRemote(Map<String, dynamic> map) {
    return Category(id: map['id'], name: map['name']);
  }

  factory Category.fromLocal(Map<String, dynamic> map) {
    return Category(
      id: map['category_id'] as int? ?? 1,
      name: map['category_name']?.toString() ?? 'غير مصنف',
    );
  }

  factory Category.undefined() {
    return const Category(id: 1, name: 'غير مصنف');
  }

  final int id;
  final String name;

  Map<String, dynamic> toMap() {
    return {
      'category_id': id,
      'category_name': name,
    };
  }
  Map<String, dynamic> toMapUpdate() {
    return toMap()..remove('category_id');
  }

  @override
  List<Object?> get props => [id];

  @override
  String toString() {
    return 'id: $id, name: $name';
  }
}
