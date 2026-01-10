import '../../../core/constants/enums.dart';

class ProductQuery {
  ProductQuery({this.search = '', this.category = ProductCategory.all});

  final String search;
  final ProductCategory category;

  bool get isSearching => search.trim().isNotEmpty;
  bool get hasCategory => category != ProductCategory.all;
  bool get hasQuery => isSearching || hasCategory;

  String get uiNotFoundText {
    if (!hasQuery) return 'لا توجد منتجات متاحة حاليًا.';

    if (hasCategory && isSearching) {
      return 'لم نتمكن من العثور على نتائج للبحث عن:\n"$search"\nضمن الفئة: (${category.label}).\nحاول تعديل كلمة البحث أو اختيار فئة أخرى.';
    }

    if (hasCategory) {
      return 'لا توجد منتجات ضمن الفئة: \n( ${category.label} )\nجرب البحث في فئة أخرى';
    }

    if (isSearching) {
      return 'لا توجد نتائج للبحث عن:\n ( $search ) \nحاول استخدام كلمات مختلفة.';
    }

    return 'لا توجد نتائج متاحة.';
  }

  ProductQuery copyWith({String? search, ProductCategory? category}) {
    return ProductQuery(
      search: search ?? this.search,
      category: category ?? this.category,
    );
  }
}
