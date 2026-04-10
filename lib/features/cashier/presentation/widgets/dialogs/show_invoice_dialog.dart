import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../invoice_sheet.dart';

Future<void> showInvoiceDialog(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return const FractionallySizedBox(
        heightFactor: 0.8,
        child: ProviderScope(
          child: InvoiceSheet(),
        ),
      );
    },
  );
}
