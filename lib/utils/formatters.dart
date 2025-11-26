import 'package:intl/intl.dart';

/// Format currency in Indonesian Rupiah
String formatCurrency(double amount) {
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  return formatter.format(amount);
}

/// Format date in Indonesian format
String formatDate(DateTime date) {
  return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
}

/// Format date with time
String formatDateTime(DateTime date) {
  return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(date);
}

/// Format relative date
String formatRelativeDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final inputDate = DateTime(date.year, date.month, date.day);

  if (inputDate == today) {
    return 'Hari ini';
  } else if (inputDate == yesterday) {
    return 'Kemarin';
  } else if (date.year == now.year) {
    return DateFormat('dd MMMM', 'id_ID').format(date);
  } else {
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }
}

/// Format percentage
String formatPercentage(double value) {
  return '${(value * 100).toStringAsFixed(1)}%';
}

/// Get month name in Indonesian
String getMonthName(int month) {
  final months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  return months[month - 1];
}

/// Parse tags from note string
List<String> parseTags(String? note) {
  if (note == null || note.isEmpty) return [];

  final regex = RegExp(r'#(\w+)');
  final matches = regex.allMatches(note);
  return matches.map((m) => m.group(1)!).toList();
}
