import 'package:flutter/material.dart';

import '../services/database_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() =>
      _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String formatPrice(double price) {
    return 'Rp${price.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final transactions =
        DatabaseService.getTransactions();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
      ),

      body: transactions.isEmpty
          ? const Center(
              child: Text(
                'Belum ada transaksi',
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction =
                    transactions[index];

                return Card(
                  child: ExpansionTile(
                    leading: const CircleAvatar(
                      child: Icon(
                        Icons.receipt,
                      ),
                    ),

                    title: Text(
                      'Transaksi #${transaction.id.substring(transaction.id.length - 6)}',
                    ),

                    subtitle: Text(
                      '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
                    ),

                    trailing: Text(
                      formatPrice(transaction.total),
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),

                    children: [
                      ...transaction.items.map(
                        (item) {
                          return ListTile(
                            title: Text(
                              item.product.name,
                            ),
                            trailing: Text(
                              '${item.quantity} x ${formatPrice(item.product.price)}',
                            ),
                          );
                        },
                      ),

                      Padding(
                        padding:
                            const EdgeInsets.all(15),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            const Text(
                              'Total Pembayaran',
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            Text(
                              formatPrice(
                                transaction.total,
                              ),
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}