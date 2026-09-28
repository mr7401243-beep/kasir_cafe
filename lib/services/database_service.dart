import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product.dart';
import '../models/transaction.dart';

class DatabaseService {
  static SupabaseClient get _client => Supabase.instance.client;

  /// Daftar menu aktif.
  static Future<List<Product>> getProducts() async {
    final rows = await _client
        .from('products')
        .select()
        .eq('is_active', true)
        .order('category')
        .order('id');
    return (rows as List)
        .map((e) => Product.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Simpan transaksi lewat fungsi `create_transaction` (atomik,
  /// total dihitung ulang di server dari harga database).
  static Future<PaymentResult> createTransaction({
    required List<CartProduct> cart,
    required double payment,
    required String method,
  }) async {
    final result = await _client.rpc('create_transaction', params: {
      'p_items': cart
          .map((c) => {'product_id': c.product.id, 'quantity': c.quantity})
          .toList(),
      'p_payment': payment,
      'p_method': method,
    });
    return PaymentResult.fromMap(Map<String, dynamic>.from(result as Map));
  }

  /// Riwayat transaksi terbaru (kasir: milik sendiri, admin: semua).
  static Future<List<CoffeeTransaction>> getTransactions() async {
    final rows = await _client
        .from('transactions')
        .select('*, transaction_items(*)')
        .order('created_at', ascending: false)
        .limit(100);
    return (rows as List)
        .map((e) => CoffeeTransaction.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}
