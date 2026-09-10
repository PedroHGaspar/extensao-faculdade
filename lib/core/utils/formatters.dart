abstract final class AppFormatters {
  static String _twoDigits(int value) => value.toString().padLeft(2, '0');

  static String date(DateTime value) =>
      '${_twoDigits(value.day)}/${_twoDigits(value.month)}/${value.year}';

  static String dateTime(DateTime value) =>
      '${date(value)} ${time(value)}';

  static String time(DateTime value) =>
      '${_twoDigits(value.hour)}:${_twoDigits(value.minute)}';

  static String currency(double? value) {
    if (value == null) return 'Não informado';
    final parts = value.toStringAsFixed(2).split('.');
    final digits = parts.first;
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      final remaining = digits.length - i;
      buffer.write(digits[i]);
      if (remaining > 1 && remaining % 3 == 1) buffer.write('.');
    }
    return 'R\$ ${buffer.toString()},${parts.last}';
  }

  static double? parseCurrency(String value) {
    final normalized = value
        .replaceAll('R\$', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
