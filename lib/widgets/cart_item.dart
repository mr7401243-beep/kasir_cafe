import 'package:flutter/material.dart';

import '../models/transaction.dart';
import '../utils/format.dart';

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

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          item.product.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(formatRupiah(item.product.price)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(onPressed: onRemove, icon: const Icon(Icons.remove)),
            Text('${item.quantity}', style: const TextStyle(fontSize: 16)),
            IconButton(onPressed: onAdd, icon: const Icon(Icons.add)),
          ],
        ),
      ),
    );
  }
}