import 'package:flutter/material.dart';

import '../models/transaction.dart';
import '../services/database_service.dart';

class PaymentScreen extends StatefulWidget {
  final List<CartProduct> cart;
  final double total;

  const PaymentScreen({
    super.key,
    required this.cart,
    required this.total,
  });

  @override
  State<PaymentScreen> createState() =>
      _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final paymentController = TextEditingController();

  String paymentMethod = 'Cash';

  double get payment {
    return double.tryParse(
          paymentController.text.replaceAll('.', ''),
        ) ??
        0;
  }

  double get change {
    return payment - widget.total;
  }

  String formatPrice(double price) {
    return 'Rp${price.toStringAsFixed(0)}';
  }

  void processPayment() {
    if (payment < widget.total) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Uang pembayaran tidak mencukupi',
          ),
        ),
      );
      return;
    }

    final transaction = CoffeeTransaction(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(),
      date: DateTime.now(),
      items: List.from(widget.cart),
      total: widget.total,
      payment: payment,
      change: change,
    );

    DatabaseService.addTransaction(transaction);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 50,
          ),

          title: const Text(
            'Pembayaran Berhasil',
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total: ${formatPrice(widget.total)}',
              ),

              Text(
                'Kembalian: ${formatPrice(change)}',
              ),
            ],
          ),

          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                Navigator.pop(
                  context,
                  true,
                );

                Navigator.pop(context);
              },
              child: const Text('SELESAI'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    paymentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            const Text(
              'TOTAL PEMBAYARAN',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              formatPrice(widget.total),
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Metode Pembayaran',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            Row(
              children: [
                Expanded(
                  child: RadioListTile(
                    title: const Text('Cash'),
                    value: 'Cash',
                    groupValue: paymentMethod,
                    onChanged: (value) {
                      setState(() {
                        paymentMethod = value!;
                      });
                    },
                  ),
                ),

                Expanded(
                  child: RadioListTile(
                    title: const Text('QRIS'),
                    value: 'QRIS',
                    groupValue: paymentMethod,
                    onChanged: (value) {
                      setState(() {
                        paymentMethod = value!;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            TextField(
              controller: paymentController,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {});
              },
              decoration: InputDecoration(
                labelText: 'Jumlah Uang Dibayar',
                prefixText: 'Rp ',
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Kembalian',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),

                    Text(
                      formatPrice(
                        change > 0 ? change : 0,
                      ),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'PROSES PEMBAYARAN',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}