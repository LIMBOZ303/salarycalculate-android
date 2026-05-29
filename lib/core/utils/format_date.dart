import 'package:intl/intl.dart';

final _dateFormat = DateFormat('dd/MM/yyyy');
final _timeFormat = DateFormat('HH:mm');
final _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

String formatDate(DateTime? date) {
  if (date == null) return '--';
  return _dateFormat.format(date.toLocal());
}

String formatTime(DateTime? date) {
  if (date == null) return '--';
  return _timeFormat.format(date.toLocal());
}

String formatDateTime(DateTime? date) {
  if (date == null) return '--';
  return _dateTimeFormat.format(date.toLocal());
}

DateTime? parseIsoDate(String? value) {
  if (value == null || value.isEmpty) return null;
  return DateTime.tryParse(value);
}

String formatHours(double? hours) {
  if (hours == null) return '--';
  final h = hours.floor();
  final m = ((hours - h) * 60).round();
  if (m == 0) return '${h}h';
  return '${h}h ${m}p';
}

String formatMinutes(int? minutes) {
  if (minutes == null || minutes == 0) return '0 phút';
  if (minutes < 60) return '$minutes phút';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (m == 0) return '$h giờ';
  return '$h giờ $m phút';
}

String monthYearLabel(int month, int year) => 'Tháng $month/$year';
