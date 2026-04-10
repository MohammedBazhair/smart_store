import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../entities/invoice.dart';
import 'print_ui_invoice_helpers.dart';

class PdfService {
  factory PdfService() => _instance ??= PdfService._();

  PdfService._();
  static PdfService? _instance;

  Future<pw.Document> createPdf(Invoice invoice) async {
    final pdf = pw.Document();
    final page = pw.Page(
      pageFormat: PdfPageFormat.roll80,
      margin: const pw.EdgeInsets.all(16),
      build: (context) {
        return pw.Column(
          children: [
            // Store Header
            pw.Text(
              invoice.storeName,
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
              textAlign: pw.TextAlign.center,
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              invoice.title,
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 12),

            // Invoice Details
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 0.5),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Column(
                children: [
                  PrintUiInvoiceHelpers.buildInfoRow(
                    'رقم الفاتورة:',
                    invoice.invoiceNumber,
                  ),
                  pw.SizedBox(height: 4),
                  PrintUiInvoiceHelpers.buildInfoRow(
                    'التاريخ:',
                    '${invoice.date}  ${invoice.time}',
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // Table Header
            pw.Divider(thickness: 1, borderStyle: pw.BorderStyle.dashed),
            pw.Row(
              children: [
                PrintUiInvoiceHelpers.headerCell('المنتج', flex: 3),
                PrintUiInvoiceHelpers.headerCell(
                  'الكمية',
                  align: pw.TextAlign.center,
                ),
                PrintUiInvoiceHelpers.headerCell(
                  'السعر',
                  align: pw.TextAlign.center,
                ),
                PrintUiInvoiceHelpers.headerCell(
                  'الإجمالي',
                  align: pw.TextAlign.right,
                ),
              ],
            ),
            pw.Divider(thickness: 1, borderStyle: pw.BorderStyle.dashed),

            // Table Items
            ...invoice.items.map((item) {
              return pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Row(
                  children: [
                    PrintUiInvoiceHelpers.cell(item.name, flex: 3),
                    PrintUiInvoiceHelpers.cell(
                      item.quantity,
                      align: pw.TextAlign.center,
                    ),
                    PrintUiInvoiceHelpers.cell(
                      item.unitPrice,
                      align: pw.TextAlign.center,
                    ),
                    PrintUiInvoiceHelpers.cell(
                      item.total,
                      align: pw.TextAlign.right,
                    ),
                  ],
                ),
              );
            }),
            pw.Divider(thickness: 1, borderStyle: pw.BorderStyle.dashed),
            pw.SizedBox(height: 8),

            // Totals
            pw.Container(
              alignment: pw.Alignment.centerLeft,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  PrintUiInvoiceHelpers.totalRow(
                    'المجموع الفرعي:',
                    invoice.subTotal,
                  ),
                  pw.SizedBox(height: 2),
                  PrintUiInvoiceHelpers.totalRow('الضريبة:', invoice.taxAmount),
                  pw.SizedBox(height: 2),
                  PrintUiInvoiceHelpers.totalRow('الخصم:', invoice.discount),
                  pw.Divider(thickness: 0.5),
                  PrintUiInvoiceHelpers.totalRow(
                    'الإجمالي النهائي:',
                    invoice.finalTotal,
                    isBold: true,
                    size: 16,
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Footer
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    invoice.subtitle,
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'نتمنى رؤيتكم مرة أخرى',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );

    pdf.addPage(page);

    return pdf;
  }
}
