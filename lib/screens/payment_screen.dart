import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/transaction.dart';
import '../services/database_service.dart';
import '../utils/format.dart';

class PaymentScreen extends StatefulWidget {
  final List<CartProduct> cart;
  final double total;

  const PaymentScreen({
    super.key,
    required this.cart,
    required this.total,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final paymentController = TextEditingController();

  String paymentMethod = 'Cash';
  bool isProcessing = false;

  bool get isCash => paymentMethod == 'Cash';

  /// Uang yang dibayarkan. QRIS selalu dianggap pas.
  double get payment {
    if (!isCash) return widget.total;
    return double.tryParse(paymentController.text) ?? 0;
  }

  double get change => payment - widget.total;

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> processPayment() async {
    if (payment < widget.total) {
      showMessage('Uang pembayaran tidak mencukupi');
      return;
    }

    setState(() => isProcessing = true);

    try {
      final result = await DatabaseService.createTransaction(
        cart: widget.cart,
        payment: payment,
        method: paymentMethod,
      );

      if (!mounted) return;
      await showSuccessDialog(result);
    } on PostgrestException catch (e) {
      if (mounted) showMessage(e.message);
    } catch (_) {
      if (mounted) {
        showMessage('Gagal menyimpan transaksi. Periksa koneksi internet.');
      }
    } finally {
      if (mounted) setState(() => isProcessing = false);
    }
  }

  Future<void> showSuccessDialog(PaymentResult result) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 50),
          title: const Text('Pembayaran Berhasil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('No. ${result.invoiceNo}'),
              const SizedBox(height: 8),
              Text('Total: ${formatRupiah(result.total)}'),
              Text('Kembalian: ${formatRupiah(result.change)}'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('SELESAI'),
            ),
          ],
        );
      },
    );

    // Tutup halaman pembayaran; true = keranjang di kasir dikosongkan.
    if (mounted) Navigator.pop(context, true);
  }

  @override
  void dispose() {
    paymentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('TOTAL PEMBAYARAN', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 5),
          Text(
            formatRupiah(widget.total),
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Metode Pembayaran',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'Cash',
                label: Text('Cash'),
                icon: Icon(Icons.payments),
              ),
              ButtonSegment(
                value: 'QRIS',
                label: Text('QRIS'),
                icon: Icon(Icons.qr_code),
              ),
            ],
            selected: {paymentMethod},
            onSelectionChanged: (selection) {
              setState(() => paymentMethod = selection.first);
            },
          ),
          const SizedBox(height: 20),
          if (isCash) ...[
            TextField(
              controller: paymentController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Jumlah Uang Dibayar',
                prefixText: 'Rp ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  paymentController.text = widget.total.round().toString();
                  setState(() {});
                },
                child: const Text('Uang pas'),
              ),
            ),
          ] else
            const Card(
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  'Pelanggan membayar melalui QRIS. Tekan tombol proses '
                  'setelah pembayaran diterima.',
                ),
              ),
            ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Kembalian', style: TextStyle(fontSize: 18)),
                  Text(
                    formatRupiah(change > 0 ? change : 0),
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
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: isProcessing ? null : processPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                foregroundColor: Colors.white,
              ),
              child: isProcessing
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('PROSES PEMBAYARAN'),
            ),
          ),
        ),
      ),
    );
  }
}
