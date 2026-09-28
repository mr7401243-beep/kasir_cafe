import 'product.dart';

/// Item di keranjang (sebelum dibayar).
class CartProduct {
  final Product product;
  int quantity;

  CartProduct({
    required this.product,
    this.quantity = 1,
  });

  double get subtotal => product.price * quantity;
}

/// Item pada transaksi yang sudah tersimpan (snapshot nama & harga saat dijual).
class TransactionItem {
  final String productName;
  final double price;
  final int quantity;
  final double subtotal;

  TransactionItem({
    required this.productName,
    required this.price,
    required this.quantity,
    required this.subtotal,
  });

  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      productName: map['product_name'] as String,
      price: (map['price'] as num).toDouble(),
      quantity: (map['quantity'] as num).toInt(),
      subtotal: (map['subtotal'] as num).toDouble(),
    );
  }
}

class CoffeeTransaction {
  final String id;
  final String invoiceNo;
  final DateTime date;
  final List<TransactionItem> items;
  final double total;
  final double payment;
  final double change;
  final String paymentMethod;

  CoffeeTransaction({
    required this.id,
    required this.invoiceNo,
    required this.date,
    required this.items,
    required this.total,
    required this.payment,
    required this.change,
    required this.paymentMethod,
  });

  factory CoffeeTransaction.fromMap(Map<String, dynamic> map) {
    final rawItems = (map['transaction_items'] as List?) ?? const [];
    return CoffeeTransaction(
      id: map['id'] as String,
      invoiceNo: map['invoice_no'] as String,
      date: DateTime.parse(map['created_at'] as String).toLocal(),
      items: rawItems
          .map((e) => TransactionItem.fromMap(e as Map<String, dynamic>))
          .toList(),
      total: (map['total'] as num).toDouble(),
      payment: (map['payment'] as num).toDouble(),
      change: (map['change_amount'] as num).toDouble(),
      paymentMethod: map['payment_method'] as String,
    );
  }
}

/// Hasil dari fungsi `create_transaction` di Supabase.
class PaymentResult {
  final String invoiceNo;
  final double total;
  final double change;

  PaymentResult({
    required this.invoiceNo,
    required this.total,
    required this.change,
  });

  factory PaymentResult.fromMap(Map<String, dynamic> map) {
    return PaymentResult(
      invoiceNo: map['invoice_no'] as String,
      total: (map['total'] as num).toDouble(),
      change: (map['change_amount'] as num).toDouble(),
    );
  }
}
