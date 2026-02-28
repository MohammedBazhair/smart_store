import '../../products/data/models/store_product_model.dart';

class AlertBackgroundParams {
  AlertBackgroundParams({
    required this.product,
    required this.daysBeforeExpire,
  });

  factory AlertBackgroundParams.fromMap(Map<String, dynamic> map) {
    return AlertBackgroundParams(
      product:
          SellerProductModel.fromRemote(map['product'] as Map<String, dynamic>),
      daysBeforeExpire: map['daysBeforeExpire'] as int,
    );
  }

  final SellerProductModel product;
  final int daysBeforeExpire;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'product': product.toMap(),
      'daysBeforeExpire': daysBeforeExpire,
    };
  }
}
