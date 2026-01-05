import 'package:workmanager/workmanager.dart';
import '../../../../core/constants/enums.dart';
import '../../../products/data/product_model.dart';
import '../../../products/domain/product.dart';
import '../../data/alert_background_params.dart';

Future<void> scheduleWorkManagerAlert(
  Product product,
  int daysBefore,
  Duration delay,
) async {
  final productModel = ProductModel.fromEntity(product);
  final alertParams = AlertBackgroundParams(
    product: productModel,
    daysBeforeExpire: daysBefore,
  );
  await Workmanager().registerOneOffTask(
    '${product.id}',
    BackgroundTask.addAlertForProduct.name,
    initialDelay: delay,
    inputData: alertParams.toMap(),
  );
}
