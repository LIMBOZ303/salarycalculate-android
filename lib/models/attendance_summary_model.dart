class AttendanceSummaryModel {
  const AttendanceSummaryModel({
    this.totalHours = 0,
    this.totalDays = 0,
    this.lateCount = 0,
    this.totalLateMinutes = 0,
    this.missingCheckOutDays = 0,
    this.month,
    this.year,
  });

  final double totalHours;
  final int totalDays;
  final int lateCount;
  final int totalLateMinutes;
  final int missingCheckOutDays;
  final int? month;
  final int? year;

  factory AttendanceSummaryModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AttendanceSummaryModel();
    return AttendanceSummaryModel(
      totalHours: _toDouble(json['totalHours'] ?? json['totalWorkingHours']) ?? 0,
      totalDays: _toInt(json['totalDays'] ?? json['workingDays']) ?? 0,
      lateCount: _toInt(json['lateCount'] ?? json['lateTimes']) ?? 0,
      totalLateMinutes: _toInt(json['totalLateMinutes'] ?? json['lateMinutes']) ?? 0,
      missingCheckOutDays:
          _toInt(json['missingCheckOutDays'] ?? json['missingCheckOut']) ?? 0,
      month: _toInt(json['month']),
      year: _toInt(json['year']),
    );
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}
