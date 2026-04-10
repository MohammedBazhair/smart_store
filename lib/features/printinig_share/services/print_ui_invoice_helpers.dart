import 'package:pdf/widgets.dart' as pw;

class PrintUiInvoiceHelpers {
  PrintUiInvoiceHelpers._();

  // 🧾 Header Cell
  static pw.Widget header(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          fontSize: 5,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  // 📦 Table Cell
  static pw.Widget cell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: const pw.TextStyle(fontSize: 7),
      ),
    );
  }

  // 💰 Total Row
  static pw.Widget totalRow(
    String title,
    String value, {
    bool isBold = false,
    double size = 10,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: size,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: size,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // ℹ️ Info Row
  static pw.Widget buildInfoRow(String title, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 7,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(
          value,
          style: const pw.TextStyle(fontSize: 7),
        ),
      ],
    );
  }
}
