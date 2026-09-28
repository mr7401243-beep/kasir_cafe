import 'package:flutter/material.dart';

import '../models/product.dart';
import '../models/transaction.dart';

import '../widgets/product_card.dart';
import '../widgets/cart_item.dart';

import 'payment_screen.dart';

class CashierScreen extends StatefulWidget {
  const CashierScreen({super.key});

  @override
  State<CashierScreen> createState() => _CashierScreenState();
}

class _CashierScreenState extends State<CashierScreen> {
  final List<Product> products = [
    Product(
      id: 1,
      name: 'Espresso',
      price: 15000,
      category: 'Coffee',
      icon: '☕',
    ),

    Product(
      id: 2,
      name: 'Americano',
      price: 18000,
      category: 'Coffee',
      icon: '☕',
    ),

    Product(
      id: 3,
      name: 'Cappuccino',
      price: 25000,
      category: 'Coffee',
      icon: '🥛',
    ),

    Product(
      id: 4,
      name: 'Latte',
      price: 25000,
      category: 'Coffee',
      icon: '☕',
    ),

    Product(
      id: 5,
      name: 'Matcha Latte',
      price: 22000,
      category: 'Non Coffee',
      icon: '🍵',
    ),

    Product(
      id: 6,
      name: 'Chocolate',
      price: 22000,
      category: 'Non Coffee',
      icon: '🍫',
    ),

    Product(
      id: 7,
      name: 'Croissant',
      price: 18000,
      category: 'Food',
      icon: '🥐',
    ),

    Product(
      id: 8,
      name: 'French Fries',
      price: 20000,
      category: 'Food',
      icon: '🍟',
    ),
  ];

  final List<CartProduct> cart = [];

  void addToCart(Product product) {
    setState(() {
      final index = cart.indexWhere(
        (item) => item.product.id == product.id,
      );

      if (index >= 0) {
        cart[index].quantity++;
      } else {
        cart.add(
          CartProduct(product: product),
        );
      }
    });
  }

  void removeFromCart(CartProduct item) {
    setState(() {
      if (item.quantity > 1) {
        item.quantity--;
      } else {
        cart.remove(item);
      }
    });
  }

  double get total {
    return cart.fold(
      0,
      (sum, item) => sum + item.subtotal,
    );
  }

  String formatPrice(double price) {
    return 'Rp${price.toStringAsFixed(0)}';
  }

  void goToPayment() {
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keranjang masih kosong'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          cart: cart,
          total: total,
        ),
      ),
    ).then((value) {
      if (value == true) {
        setState(() {
          cart.clear();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kasir FEY COFFEE'),
      ),

      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: products.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) {
                return ProductCard(
                  product: products[index],
                  onTap: () {
                    addToCart(products[index]);
                  },
                );
              },
            ),
          ),

          Container(
            height: 280,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 5,
                  color: Colors.grey.withOpacity(0.3),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'KERANJANG PESANAN',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: cart.isEmpty
                      ? const Center(
                          child: Text(
                            'Belum ada pesanan',
                          ),
                        )
                      : ListView.builder(
                          itemCount: cart.length,
                          itemBuilder: (context, index) {
                            final item = cart[index];

                            return CartItem(
                              item: item,
                              onAdd: () {
                                setState(() {
                                  item.quantity++;
                                });
                              },
                              onRemove: () {
                                removeFromCart(item);
                              },
                            );
                          },
                        ),
                ),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TOTAL',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      formatPrice(total),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: goToPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'LANJUT KE PEMBAYARAN',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}