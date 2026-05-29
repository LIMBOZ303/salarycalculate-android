import '../core/utils/format_date.dart';

class TodayAttendanceModel {
  const TodayAttendanceModel({
    this.id,
    this.status = 'not_checked_in',
    this.checkInTime,
    this.checkOutTime,
    this.totalHours = 0,
    this.lateMinutes = 0,
    this.breakMinutes = 0,
    this.note,
    this.suspicious = false,
    this.suspiciousReasons = const [],
    this.isLocked = false,
  });

  final String? id;
  final String status;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final double totalHours;
  final int lateMinutes;
  final int breakMinutes;
  final String? note;
  final bool suspicious;
  final List<String> suspiciousReasons;
  final bool isLocked;

  bool get canCheckIn {
    const allowed = ['not_checked_in', ''];
    return allowed.contains(status.toLowerCase()) || status.isEmpty;
  }

  bool get canCheckOut {
    const allowed = ['checked_in', 'late'];
    return allowed.contains(status.toLowerCase());
  }

  bool get isCompleted => status.toLowerCase() == 'completed';

  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'not_checked_in':
        return 'Chưa chấm vào';
      case 'checked_in':
        return 'Đã chấm vào';
      case 'late':
        return 'Đi trễ';
      case 'completed':
        return 'Hoàn tất ca';
      case 'absent':
        return 'Vắng';
      default:
        return status.isEmpty ? 'Chưa chấm vào' : status;
    }
  }

  /// Parse payload GET /attendance/me/today hoặc check-in/out.
  factory TodayAttendanceModel.fromApiPayload(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) {
      return const TodayAttendanceModel();
    }

    Map<String, dynamic> source;
    if (data['attendance'] is Map<String, dynamic>) {
      source = Map<String, dynamic>.from(data['attendance'] as Map);
      final outerStatus = data['status']?.toString();
      if (outerStatus != null && outerStatus.isNotEmpty) {
        source['status'] = outerStatus;
      }
    } else {
      source = data;
    }

    return TodayAttendanceModel.fromJson(source);
  }

  factory TodayAttendanceModel.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) {
      return const TodayAttendanceModel();
    }

    final reasons = json['suspiciousReasons'];
    List<String> reasonList = [];
    if (reasons is List) {
      reasonList = reasons.map((e) => e.toString()).toList();
    }

    return TodayAttendanceModel(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      status: json['status']?.toString() ?? 'not_checked_in',
      checkInTime: parseIsoDate(json['checkInTime']?.toString()),
      checkOutTime: parseIsoDate(json['checkOutTime']?.toString()),
      totalHours: _toDouble(json['totalHours'] ?? json['workingHours']) ?? 0,
      lateMinutes: _toInt(json['lateMinutes']) ?? 0,
      breakMinutes: _toInt(json['breakMinutes']) ?? 0,
      note: json['note']?.toString(),
      suspicious: json['suspicious'] == true || json['isSuspicious'] == true,
      suspiciousReasons: reasonList,
      isLocked: json['isLocked'] == true,
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

class AttendanceHistoryItem {
  const AttendanceHistoryItem({
    this.id,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    this.totalHours = 0,
    this.status = '',
    this.lateMinutes = 0,
    this.suspicious = false,
    this.note,
    this.branchName,
  });

  final String? id;
  final DateTime date;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final double totalHours;
  final String status;
  final int lateMinutes;
  final bool suspicious;
  final String? note;
  final String? branchName;

  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Hoàn tất';
      case 'late':
        return 'Đi trễ';
      case 'checked_in':
        return 'Chưa chấm ra';
      case 'absent':
        return 'Vắng';
      default:
        return status.isEmpty ? '--' : status;
    }
  }

  factory AttendanceHistoryItem.fromJson(Map<String, dynamic> json) {
    final dateStr = json['date']?.toString() ??
        json['workDate']?.toString() ??
        json['checkInTime']?.toString();

    String? branchName;
    final branchId = json['branchId'];
    if (branchId is Map) {
      branchName = branchId['name']?.toString();
    }

    return AttendanceHistoryItem(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      date: parseIsoDate(dateStr) ?? DateTime.now(),
      checkInTime: parseIsoDate(json['checkInTime']?.toString()),
      checkOutTime: parseIsoDate(json['checkOutTime']?.toString()),
      totalHours: TodayAttendanceModel._toDouble(json['totalHours'] ?? json['workingHours']) ?? 0,
      status: json['status']?.toString() ?? '',
      lateMinutes: TodayAttendanceModel._toInt(json['lateMinutes']) ?? 0,
      suspicious: json['suspicious'] == true || json['isSuspicious'] == true,
      note: json['note']?.toString(),
      branchName: branchName,
    );
  }
}
