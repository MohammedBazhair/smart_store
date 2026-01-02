
import '../../products/data/product_model.dart';

class AlertBackgroundParams {
  AlertBackgroundParams({
    required this.product,
    required this.daysBeforeExpire,
  });

  factory AlertBackgroundParams.fromMap(Map<String, dynamic> map) {
    return AlertBackgroundParams(
      product: ProductModel.fromMap(map['product'] as Map<String, dynamic>),
      daysBeforeExpire: map['daysBeforeExpire'] as int,
    );
  }

  final ProductModel product;
  final int daysBeforeExpire;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'product': product.toMap(),
      'daysBeforeExpire': daysBeforeExpire,
    };
  }
}
