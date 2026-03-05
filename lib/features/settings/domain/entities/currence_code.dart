enum CurrencyCode {
  YER(label: 'يمني'),
  USD(label: 'دولار'),
  SAR(label: 'سعودي');

  const CurrencyCode({required this.label});
  final String label;

 static CurrencyCode get theDefault => YER;
}
