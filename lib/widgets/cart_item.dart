import 'package:flutter/material.dart';
import '../models/transaction.dart';

class CartItem extends StatelessWidget {
  final CartProduct item;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const CartItem({
    super.key,
    required this.item,
    required this.onAdd,
    required this.onRemove,
  });

  String formatPrice(double price) {
    return 'Rp${price.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          item.product.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Text(
          formatPrice(item.product.price),
        ),

        trailing: SizedBox(
          width: 130,
          child: Row(
            children: [
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.remove),
              ),

              Text(
                '${item.quantity}',
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),

              IconButton(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ),
    );
  }
}