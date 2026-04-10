import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../entities/invoice.dart';
import 'pdf_service.dart';

class ShareService {
  factory ShareService() => _instance ??= ShareService._();
  ShareService._();
  static ShareService? _instance;

  Future<void> shareInvoice(Invoice invoice) async {
    final pdf = await PdfService().createPdf(invoice);
    final bytes = await pdf.save();
    final dir = await getTemporaryDirectory();
    final fileName = 'فاتورة - ${invoice.title}${invoice.time}';
    final file = File('${dir.path}/$fileName.pdf');
    await file.writeAsBytes(bytes);
    await shareFile(file.path, fileName);
  }
}

Future<ShareResult> shareFile(String filePath, String desc) async {
  final params = ShareParams(
    text: desc,
    files: [XFile(filePath)],
  );
  final result = await SharePlus.instance.share(params);

  return result;
}
