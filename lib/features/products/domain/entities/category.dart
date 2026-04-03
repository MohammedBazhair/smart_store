import 'package:equatable/equatable.dart';

class Category extends Equatable {
  const Category({required this.id, required this.name, required this.updatedAt});

  factory Category.fromRemote(Map<String, dynamic> map) {
    return Category(id: map['id'], name: map['name'], updatedAt: DateTime.parse(map['updated_at']));
  }

  factory Category.fromLocal(Map<String, dynamic> map) {
    return Category(
      id: map['category_id'] as int? ?? 1,
      name: map['category_name']?.toString() ?? 'غير مصنف',
      updatedAt: DateTime.parse(map['category_updated_at']),
    );
  }

  factory Category.undefined() {
    return Category(id: 1, name: 'غير مصنف', updatedAt: DateTime.now().toUtc());
  }

  final int id;
  final String name;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() {
    return {
      'category_id': id,
      'category_name': name,
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };
  }
  Map<String, dynamic> toMapUpdate() {
    return toMap()..remove('category_id');
  }

@override
  List<Object?> get props => [id, name, updatedAt];

  @override
  String toString() {
    return 'id: $id, name: $name, updatedAt: $updatedAt';
  }
}
