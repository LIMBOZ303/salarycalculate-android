import 'package:intl/intl.dart';

final _currencyFormatter = NumberFormat('#,###', 'vi_VN');

/// Tiền: 10.000.000 đ
String formatCurrency(num? amount, {bool useVndSuffix = false}) {
  if (amount == null) return '--';
  final value = amount.toDouble();
  if (value == 0) return '0 ${useVndSuffix ? 'VND' : 'đ'}';
  final formatted = _currencyFormatter.format(value.round());
  return useVndSuffix ? '$formatted VND' : '$formatted đ';
}

/// Giờ dạng thập phân: 8h hoặc 8.5h
String formatHoursDecimal(double? hours) {
  if (hours == null) return '--';
  if (hours == 0) return '0h';
  final whole = hours.truncateToDouble();
  if ((hours - whole).abs() < 0.05) {
    return '${whole.toInt()}h';
  }
  final rounded = (hours * 10).round() / 10;
  if (rounded == rounded.roundToDouble()) {
    return '${rounded.toInt()}h';
  }
  return '${rounded}h';
}
