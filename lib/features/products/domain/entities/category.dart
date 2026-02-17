class Category {
  Category({required this.id, required this.name});

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(id: map['id'], name: map['name']);
  }

  factory Category.undefined() {
    return Category(id: 1, name: 'غير مصنف');
  }

  final int id;
  final String name;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  
}
