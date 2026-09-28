import 'package:flutter_test/flutter_test.dart';

import 'package:kasir_cafe/models/product.dart';
import 'package:kasir_cafe/models/transaction.dart';
import 'package:kasir_cafe/utils/format.dart';

void main() {
  test('formatRupiah memberi pemisah ribuan', () {
    expect(formatRupiah(0), 'Rp0');
    expect(formatRupiah(15000), 'Rp15.000');
    expect(formatRupiah(1250000), 'Rp1.250.000');
  });

  test('subtotal keranjang = harga x jumlah', () {
    final product = Product(
      id: 1,
      name: 'Espresso',
      price: 15000,
      category: 'Coffee',
      icon: '☕',
    );
    final item = CartProduct(product: product, quantity: 3);
    expect(item.subtotal, 45000);
  });

  test('Product.fromMap membaca data dari Supabase', () {
    final product = Product.fromMap({
      'id': 2,
      'name': 'Americano',
      'price': 18000,
      'category': 'Coffee',
      'icon': '☕',
    });
    expect(product.name, 'Americano');
    expect(product.price, 18000.0);
  });
}
