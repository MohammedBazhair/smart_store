import 'package:pdf/widgets.dart' as pw;

class PrintUiInvoiceHelpers {
  PrintUiInvoiceHelpers._();

  static pw.Widget headerCell(
    String text, {
    int flex = 1,
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Expanded(
      flex: flex,
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
      ),
    );
  }

  static pw.Widget cell(
    String text, {
    int flex = 1,
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Expanded(
      flex: flex,
      child: pw.Text(
        text,
        textAlign: align,
        style: const pw.TextStyle(fontSize: 12),
      ),
    );
  }

  static pw.Widget totalRow(
    String title,
    String value, {
    bool isBold = false,
    double size = 12,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontWeight: isBold ? pw.FontWeight.bold : null,
            fontSize: size,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontWeight: isBold ? pw.FontWeight.bold : null,
            fontSize: size,
          ),
        ),
      ],
    );
  }

  static pw.Row buildInfoRow(String title, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
        ),
        pw.Text(value, style: const pw.TextStyle(fontSize: 12)),
      ],
    );
  }
}
