import 'package:equatable/equatable.dart';

import 'category.dart';

class ProductQuery extends Equatable {
  const ProductQuery({this.search = '', this.category});

  final String search;
  final Category? category;

  bool get isSearching => search.trim().isNotEmpty;
  bool get hasCategory => category != null;
  bool get hasQuery => isSearching || hasCategory;

  String get uiNotFoundText {
    if (!hasQuery) return 'لا توجد منتجات متاحة حاليًا.';

    if (hasCategory && isSearching) {
      return 'لم نتمكن من العثور على نتائج للبحث عن:\n"$search"\nضمن الفئة: (${category!.name}).\nحاول تعديل كلمة البحث أو اختيار فئة أخرى.';
    }

    if (hasCategory) {
      return 'لا توجد منتجات ضمن الفئة: \n( ${category!.name} )\nجرب البحث في فئة أخرى';
    }

    if (isSearching) {
      return 'لا توجد نتائج للبحث عن:\n ( $search ) \nحاول استخدام كلمات مختلفة.';
    }

    return 'لا توجد نتائج متاحة.';
  }

  ProductQuery copyWith({String? search, Category? category, bool clearCategory= false}) {
    return ProductQuery(
      search: search ?? this.search,
      category:clearCategory? null: category ?? this.category,
    );
  }

  @override
  String toString() => 'ProductQuery(search: $search, category: $category)';

  @override
  List<Object?> get props => [search, category];
}
