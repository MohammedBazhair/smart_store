import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'category.dart';

enum ProductExpirationStatus {
  allProducts,
  expiredProducts,
  nearbyExpiredProducts
}

enum ProductSortType {
  expiryAsc(label: 'تاريخ الانتهاء (الأقرب)', icon: Icons.date_range),
  expiryDesc(label: 'تاريخ الانتهاء (الأبعد)', icon: Icons.event_busy),
  quantityAsc(
    label: 'الكمية (الأقل أولاً)',
    icon: Icons.keyboard_double_arrow_up_rounded,
  ),
  quantityDesc(
    label: 'الكمية (الأكثر أولاً)',
    icon: Icons.keyboard_double_arrow_down_rounded,
  );

  const ProductSortType({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

class ProductQuery extends Equatable {
  const ProductQuery({
    this.search = '',
    this.category,
    this.sortType = ProductSortType.expiryAsc,
    this.statusType = ProductExpirationStatus.allProducts,
  });

  final String search;
  final Category? category;
  final ProductSortType sortType;
  final ProductExpirationStatus statusType;

  bool get isSearching => search.trim().isNotEmpty;
  bool get hasCategory => category != null;

  String get uiNotFoundText {
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

 static const _sentinalValue = Object();

  ProductQuery copyWith({
    String? search,
    Category? category,
    bool clearCategory = false,
    ProductSortType? sortType,
    ProductExpirationStatus? statusType,
  }) {
    return ProductQuery(
      search: search ?? this.search,
      category: clearCategory ? null : category ?? this.category,
      sortType: sortType ?? this.sortType,
      statusType: statusType ?? this.statusType,
    );
  }

  @override
  String toString() =>
      'ProductQuery(search: $search, category: $category, sortType: $sortType)';

  @override
  List<Object?> get props => [search, category, sortType];
}
