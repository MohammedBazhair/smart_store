enum ProductCategory {
  dairy(label: 'ألبان ومنتجاتها'),
  medicine(label: 'أدوية ومستحضرات طبية'),
  drinks(label: 'مشروبات'),
  food(label: 'مواد غذائية وأساسية'),
  sweets(label: 'حلويات ومخبوزات'),
  vegetables(label: 'خضروات وفواكه'),
  meat(label: 'لحوم ودواجن'),
  oils(label: 'زيوت ودهون'),
  spices(label: 'بهارات وتوابل'),
  cleaning(label: 'منظفات ومواد تنظيف'),
  household(label: 'مستلزمات منزلية'),
  office(label: 'معدات وأدوات مكتبية'),
  others(label: 'أخرى');

  const ProductCategory({required this.label});
  final String label;

 
}

enum Currency {
  YER(label: 'ريال يمني'),
  SAR(label: 'ريال سعودي');

  const Currency({required this.label});
  final String label;
}
