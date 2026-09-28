import 'product.dart';

class CartProduct {
  final Product product;
  int quantity;

  CartProduct({
    required this.product,
    this.quantity = 1,
  });

  double get subtotal {
    return product.price * quantity;
  }
}

class CoffeeTransaction {
  final String id;
  final DateTime date;
  final List<CartProduct> items;
  final double total;
  final double payment;
  final double change;

  CoffeeTransaction({
    required this.id,
    required this.date,
    required this.items,
    required this.total,
    required this.payment,
    required this.change,
  });
}