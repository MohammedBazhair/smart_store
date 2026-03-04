import 'package:workmanager/workmanager.dart';
import '../../../../core/constants/enums.dart';
import '../../../products/data/models/store_product_model.dart';
import '../../../products/domain/entities/store_product.dart';
import '../../data/alert_background_params.dart';

Future<void> scheduleWorkManagerAlert(
  StoreProduct product,
  int daysBefore,
  Duration delay,
) async {
  final productModel = StoreProductModel.fromEntity(product);
  final alertParams = AlertBackgroundParams(
    product: productModel,
    daysBeforeExpire: daysBefore,
  );
  await Workmanager().registerOneOffTask(
    '${product.globalProduct.id}',
    BackgroundTask.addAlertForProduct.name,
    initialDelay: delay,
    inputData: alertParams.toMap(),
  );
}
