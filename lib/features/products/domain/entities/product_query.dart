import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'category.dart';

enum ProductSortType {
  none(label:  'الافتراضي',icon:  Icons.sort),
  quantityAsc(label: 'الكمية (الأقل أولاً)',icon:  Icons.keyboard_double_arrow_up_rounded),
  quantityDesc(label: 'الكمية (الأكثر أولاً)',icon:  Icons.keyboard_double_arrow_down_rounded),
  expiryAsc(label: 'تاريخ الانتهاء (الأقرب)',icon:  Icons.date_range),
  expiryDesc(label: 'تاريخ الانتهاء (الأبعد)',icon:  Icons.event_busy);

  const ProductSortType({required this.label, required this.icon});

  final String label;
  final IconData icon;
}



class ProductQuery extends Equatable {
  const ProductQuery({
    this.search = '',
    this.category,
    this.sortType = ProductSortType.none,
  });

  final String search;
  final Category? category;
  final ProductSortType sortType;

  bool get isSearching => search.trim().isNotEmpty;
  bool get hasCategory => category != null;
  bool get hasSort => sortType != ProductSortType.none;
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

  ProductQuery copyWith({
    String? search,
    Category? category,
    bool clearCategory = false,
    ProductSortType? sortType,
  }) {
    return ProductQuery(
      search: search ?? this.search,
      category: clearCategory ? null : category ?? this.category,
      sortType: sortType ?? this.sortType,
    );
  }

  @override
  String toString() =>
      'ProductQuery(search: $search, category: $category, sortType: $sortType)';

  @override
  List<Object?> get props => [search, category, sortType];
}
