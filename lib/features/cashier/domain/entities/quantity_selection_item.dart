class QuantitySelectionItem {
  QuantitySelectionItem({this.productName = '', this.quantity = 0});

  final String productName;
  final int quantity;

  QuantitySelectionItem copyWith({
    String? productName,
    int? quantity,
  }) {
    return QuantitySelectionItem(
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
    );
  }
}
