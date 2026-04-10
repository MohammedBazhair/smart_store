import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../entities/invoice.dart';
import 'print_ui_invoice_helpers.dart';

class PdfService {
  factory PdfService() => _instance ??= PdfService._();

  PdfService._();
  static PdfService? _instance;

  Future<pw.Font> _loadRegularFont() async {
    final fontData = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
    return pw.Font.ttf(fontData);
  }

  Future<pw.Font> _loadBoldFont() async {
    final fontData = await rootBundle.load('assets/fonts/Cairo-Bold.ttf');
    return pw.Font.ttf(fontData);
  }

  Future<pw.Document> createPdf(Invoice invoice) async {
    final baseFont = await _loadRegularFont();
    final boldFont = await _loadBoldFont();

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: baseFont,
        bold: boldFont,
      ),
    );

    pdf.addPage(
      pw.Page(
        textDirection: pw.TextDirection.rtl,
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.all(10),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // 🏪 HEADER
              pw.Text(
                invoice.storeName,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 4),

              pw.Text(
                invoice.title,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 7,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 10),

              // 📦 INFO BOX
              pw.Container(
                padding: const pw.EdgeInsets.all(6),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5, color: PdfColors.grey300),
                ),
                child: pw.Column(
                  children: [
                    PrintUiInvoiceHelpers.buildInfoRow(
                      'رقم الفاتورة',
                      invoice.invoiceNumber,
                    ),
                    pw.SizedBox(height: 3),
                    PrintUiInvoiceHelpers.buildInfoRow(
                      'التاريخ',
                      '${invoice.date} - ${invoice.time}',
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 10),

              // 📊 REVERSED TABLE (RTL POS STYLE)
              pw.Table(
                border: pw.TableBorder.all(
                  width: 0.3,
                  color: PdfColors.grey400,
                ),
                columnWidths: const {
                  0: pw.FlexColumnWidth(1.5), // الإجمالي
                  1: pw.FlexColumnWidth(), // السعر
                  2: pw.FlexColumnWidth(), // الكمية
                  3: pw.FlexColumnWidth(3), // المنتج
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    children: [
                      PrintUiInvoiceHelpers.header('الإجمالي'),
                      PrintUiInvoiceHelpers.header('السعر'),
                      PrintUiInvoiceHelpers.header('الكمية'),
                      PrintUiInvoiceHelpers.header('المنتج'),
                    ],
                  ),

                  // 🔥 ITEMS (REVERSED)
                  ...invoice.items.map(
                    (item) => pw.TableRow(
                      children: [
                        PrintUiInvoiceHelpers.cell(item.total),
                        PrintUiInvoiceHelpers.cell(item.unitPrice.toString()),
                        PrintUiInvoiceHelpers.cell(
                          item.quantity.toString(),
                        ),
                        PrintUiInvoiceHelpers.cell(item.name),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 10),

              // 💰 TOTALS
              pw.Column(
                children: [
                  PrintUiInvoiceHelpers.totalRow(
                    'المجموع الفرعي',
                    invoice.subTotal,
                    size: 7,
                  ),
                  PrintUiInvoiceHelpers.totalRow(
                    'الضريبة',
                    invoice.taxAmount,
                    size: 7,
                  ),
                  PrintUiInvoiceHelpers.totalRow(
                    'الخصم',
                    invoice.discount,
                    size: 7,
                  ),
                  pw.SizedBox(height: 10),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: pw.BoxDecoration(
                      border:
                          pw.Border.all(width: 0.5, color: PdfColors.grey400),
                    ),
                    child: PrintUiInvoiceHelpers.totalRow(
                      'الإجمالي النهائي',
                      invoice.finalTotal,
                      isBold: true,
                      size: 8,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 12),

              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      invoice.subtitle,
                      style: pw.TextStyle(
                        fontSize: 7,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'شكرا لزيارتكم',
                      style: const pw.TextStyle(fontSize: 7),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }
}
