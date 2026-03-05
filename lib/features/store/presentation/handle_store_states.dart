import 'package:flutter/material.dart';

import '../../../core/constants/enums.dart';
import '../../../core/extensions/extensions.dart';
import 'controller/store_state.dart';

Future<void> handleStoreStates(
  StoreEventState event,
  BuildContext context,
) async {
  switch (event) {
    case InitialStoreEvent():
    case LoadMyStoresEvent():
    case SelectStoreEvent():
    case LoadinMyStoresEvent():
      break;
    case CreateStoreEvent(:final storeName):
      context.showSnakbar(
        'تم انشاء $storeName بنجاح',
        type: SnackBarType.success,
      );

    case AddStoreMemberEvent(:final member):
      context.showSnakbar(
        'تم إضافة العضو صاحب الرقم ${member.memberPhone}إلى متجرك بنجاح',
        type: SnackBarType.success,
      );

    case RemoveStoreMemberEvent():
      context.showSnakbar(
        'تم ازالة العضو من المتجر بنجاح',
        type: SnackBarType.success,
      );
    case ErrorStoreEvent(:final error):
      context.showSnakbar(error, type: SnackBarType.error);
  }
}
