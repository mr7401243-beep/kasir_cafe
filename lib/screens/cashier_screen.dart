import 'package:flutter/material.dart';

import '../models/product.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';
import '../utils/format.dart';
import '../widgets/cart_item.dart';
import '../widgets/product_card.dart';
import 'payment_screen.dart';
class CashierScreen extends StatefulWidget {
  const CashierScreen({super.key});

  @override
  State<CashierScreen> createState() => _CashierScreenState();
}

class _CashierScreenState extends State<CashierScreen> {
  late Future<List<Product>> productsFuture;

  final List<CartProduct> cart = [];

  @override
  void initState() {
    super.initState();
    productsFuture = DatabaseService.getProducts();
  }

  void reloadProducts() {
    setState(() {
      productsFuture = DatabaseService.getProducts();
    });
  }

  void addToCart(Product product) {
    setState(() {
      final index = cart.indexWhere((item) => item.product.id == product.id);

      if (index >= 0) {
        cart[index].quantity++;
      } else {
        cart.add(CartProduct(product: product));
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

  double get total => cart.fold(0.0, (sum, item) => sum + item.subtotal);

  Future<void> goToPayment() async {
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keranjang masih kosong')),
      );
      return;
    }

    final paid = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(cart: List.of(cart), total: total),
      ),
    );

    if (paid == true && mounted) {
      setState(() => cart.clear());
    }
  }

  Widget buildProductGrid() {
    return FutureBuilder<List<Product>>(
      future: productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Gagal memuat menu'),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: reloadProducts,
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        final products = snapshot.data ?? [];

        if (products.isEmpty) {
          return const Center(child: Text('Belum ada menu'));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.85,
          ),
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(
              product: product,
              onTap: () => addToCart(product),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kasir COFFEE COMET')),
      body: Column(
        children: [
          Expanded(child: buildProductGrid()),
          Container(
            height: 280,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 5,
                  color: Colors.grey.withValues(alpha: 0.3),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'KERANJANG PESANAN',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: cart.isEmpty
                      ? const Center(child: Text('Belum ada pesanan'))
                      : ListView.builder(
                          itemCount: cart.length,
                          itemBuilder: (context, index) {
                            final item = cart[index];
                            return CartItem(
                              item: item,
                              onAdd: () => setState(() => item.quantity++),
                              onRemove: () => removeFromCart(item),
                            );
                          },
                        ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TOTAL',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      formatRupiah(total),
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
                    child: const Text('LANJUT KE PEMBAYARAN'),
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
