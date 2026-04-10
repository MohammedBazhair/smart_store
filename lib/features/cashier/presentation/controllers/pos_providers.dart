import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../domain/entities/quantity_selection_item.dart';
import 'pos_controller.dart';
import 'pos_state.dart';

final quantitySelectionProvider =
    StateProvider((ref) => QuantitySelectionItem());

final posControllerProvider = NotifierProvider<PosController, PosState>(() {
  return PosController();
});
