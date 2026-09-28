import 'package:flutter/material.dart';

import '../models/transaction.dart';
import '../services/database_service.dart';
import '../utils/format.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<CoffeeTransaction>> transactionsFuture;

  @override
  void initState() {
    super.initState();
    transactionsFuture = DatabaseService.getTransactions();
  }

  Future<void> reload() async {
    final future = DatabaseService.getTransactions();
    setState(() => transactionsFuture = future);
    try {
      await future;
    } catch (_) {
      // Error ditampilkan oleh FutureBuilder.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Transaksi')),
      body: FutureBuilder<List<CoffeeTransaction>>(
        future: transactionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Gagal memuat riwayat'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: reload,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final transactions = snapshot.data ?? [];

          if (transactions.isEmpty) {
            return const Center(child: Text('Belum ada transaksi'));
          }

          return RefreshIndicator(
            onRefresh: reload,
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];

                return Card(
                  child: ExpansionTile(
                    leading: const CircleAvatar(child: Icon(Icons.receipt)),
                    title: Text('No. ${transaction.invoiceNo}'),
                    subtitle: Text(
                      '${formatDateTime(transaction.date)} • '
                      '${transaction.paymentMethod}',
                    ),
                    trailing: Text(
                      formatRupiah(transaction.total),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    children: [
                      ...transaction.items.map(
                        (item) => ListTile(
                          title: Text(item.productName),
                          trailing: Text(
                            '${item.quantity} x ${formatRupiah(item.price)}',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          children: [
                            _summaryRow('Total Pembayaran', transaction.total,
                                bold: true),
                            _summaryRow('Dibayar', transaction.payment),
                            _summaryRow('Kembalian', transaction.change),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _summaryRow(String label, double value, {bool bold = false}) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(formatRupiah(value), style: style),
        ],
      ),
    );
  }
}
