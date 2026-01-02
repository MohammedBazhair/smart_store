/// أدوات للتعامل مع العملات
class CurrencyUtils {
  /// تحويل السعر من SAR إلى YER
  static double convertToYER(double amount, double exchangeRate) {
    return amount * exchangeRate;
  }

  /// تحويل السعر من YER إلى SAR
  static double convertToSAR(double amount, double exchangeRate) {
    return amount / exchangeRate;
  }

  /// تنسيق السعر للعرض
  static String formatPrice(double price, String currency) {
    return '${price.toStringAsFixed(2)} $currency';
  }

  /// تنسيق السعر مع التحويل
  static String formatPriceWithConversion(
    double price,
    String fromCurrency,
    String toCurrency,
    double exchangeRate,
  ) {
    double convertedPrice = price;
    if (fromCurrency == 'SAR' && toCurrency == 'YER') {
      convertedPrice = convertToYER(price, exchangeRate);
    } else if (fromCurrency == 'YER' && toCurrency == 'SAR') {
      convertedPrice = convertToSAR(price, exchangeRate);
    }
    return formatPrice(convertedPrice, toCurrency);
  }
}

