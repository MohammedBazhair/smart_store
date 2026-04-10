import 'package:printing/printing.dart';

import '../entities/invoice.dart';
import 'pdf_service.dart';

class PrintService {
  factory PrintService() => _instance ??= PrintService._();
  PrintService._();
  static PrintService? _instance;

  Future<void> printInvoice(Invoice invoice) async {
    final pdf = await PdfService().createPdf(invoice);

    await Printing.layoutPdf(
      onLayout: (format) => pdf.save(),
      outputType: OutputType.photo,
    );
  }
}





