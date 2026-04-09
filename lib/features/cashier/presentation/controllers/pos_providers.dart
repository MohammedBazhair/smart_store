import 'package:flutter_riverpod/legacy.dart';

import '../../domain/entities/quantity_selection_item.dart';

final quantitySelectionProvider =
    StateProvider((ref) => QuantitySelectionItem());
