/// Format angka ke Rupiah dengan pemisah ribuan. Contoh: 15000 -> Rp15.000
String formatRupiah(num value) {
  final digits = value.round().abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return '${value.round() < 0 ? '-' : ''}Rp$buffer';
}

/// Format tanggal: 28/09/2026 14:05
String formatDateTime(DateTime date) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(date.day)}/${two(date.month)}/${date.year} '
      '${two(date.hour)}:${two(date.minute)}';
}
