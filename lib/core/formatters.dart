import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  static String currency(num amount) => _currency.format(amount);

  static String weight(double kg) {
    if (kg >= 1) return '${kg.toStringAsFixed(kg % 1 == 0 ? 0 : 1)} kg';
    return '${(kg * 1000).toStringAsFixed(0)} gr';
  }

  static String date(DateTime dt) =>
      DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(dt);

  static String dateShort(DateTime dt) =>
      DateFormat('d MMM yyyy', 'id_ID').format(dt);

  static String dateTime(DateTime dt) =>
      DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(dt);

  static String time(DateTime dt) => DateFormat('HH:mm').format(dt);

  static String countdown(Duration d) {
    final h = d.inHours.remainder(24).toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  static String phone(String p) {
    final clean = p.replaceAll(RegExp(r'\D'), '');
    if (clean.startsWith('62')) return '0${clean.substring(2)}';
    return clean;
  }
}
