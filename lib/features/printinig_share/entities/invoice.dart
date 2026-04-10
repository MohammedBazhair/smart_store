class Invoice {
  Invoice({
    required this.storeName,
    required this.invoiceNumber,
    required this.date,
    required this.time,
    required this.items,
    required this.subTotal,
    required this.taxAmount,
    required this.discount,
    required this.total,
    required this.finalTotal,
    this.title = 'فاتورة مبيعات',
    this.subtitle = 'شكراً لتسوقكم معنا',
  });

  final String storeName;
  final String invoiceNumber;
  final String title;
  final String subtitle;
  final String date;
  final String time;
  final String subTotal;
  final String taxAmount;
  final String discount;
  final String total;
  final String finalTotal;
  final Iterable<InvoiceItem> items;
}

class InvoiceItem {
  InvoiceItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  final String name;
  final String quantity;
  final String unitPrice;
  final String total;
}
