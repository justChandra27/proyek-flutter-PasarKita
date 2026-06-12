String formatRupiah(double price) {
  final p = price.toInt().toString();
  final buffer = StringBuffer();
  for (int i = 0; i < p.length; i++) {
    if (i > 0 && (p.length - i) % 3 == 0) buffer.write('.');
    buffer.write(p[i]);
  }
  return 'Rp $buffer';
}
