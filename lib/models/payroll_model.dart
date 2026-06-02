import '../core/utils/format_date.dart';

class PayrollModel {
  const PayrollModel({
    this.id,
    this.employeeId,
    this.userId,
    this.branchId,
    this.month,
    this.year,
    this.employeeCode = '--',
    this.fullName = '--',
    this.branchName = '--',
    this.position = '--',
    this.hourlyRateSnapshot = 0,
    this.totalHours = 0,
    this.workingDays = 0,
    this.completedDays = 0,
    this.lateCount = 0,
    this.lateMinutes = 0,
    this.missingCheckoutDays = 0,
    this.baseSalary = 0,
    this.heldCurrentAmount = 0,
    this.carryInHeldAmount = 0,
    this.totalPenalty = 0,
    this.totalFixedDeduction = 0,
    this.totalOtherDeduction = 0,
    this.totalBonus = 0,
    this.totalDeductions = 0,
    this.grossSalary = 0,
    this.payableAmount = 0,
    this.status = '',
    this.payDate,
    this.paidAt,
    this.note,
  });

  final String? id;
  final String? employeeId;
  final String? userId;
  final String? branchId;
  final int? month;
  final int? year;
  final String employeeCode;
  final String fullName;
  final String branchName;
  final String position;
  final double hourlyRateSnapshot;
  final double totalHours;
  final int workingDays;
  final int completedDays;
  final int lateCount;
  final int lateMinutes;
  final int missingCheckoutDays;
  final double baseSalary;
  final double heldCurrentAmount;
  final double carryInHeldAmount;
  final double totalPenalty;
  final double totalFixedDeduction;
  final double totalOtherDeduction;
  final double totalBonus;
  final double totalDeductions;
  final double grossSalary;
  final double payableAmount;
  final String status;
  final DateTime? payDate;
  final DateTime? paidAt;
  final String? note;

  bool get hasData => id != null && id!.isNotEmpty;

  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'draft':
        return 'Nháp';
      case 'confirmed':
        return 'Đã chốt';
      case 'paid':
        return 'Đã thanh toán';
      default:
        return status.isEmpty ? '--' : status;
    }
  }

  String? get expectedPayDateLabel {
    if (paidAt != null) return 'Đã trả: ${formatDate(paidAt)}';
    if (payDate != null) return 'Ngày trả dự kiến: ${formatDate(payDate)}';
    return null;
  }

  factory PayrollModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PayrollModel();
    return PayrollModel(
      id: _str(json['_id'] ?? json['id']),
      employeeId: _str(json['employeeId'] ?? json['employee']),
      userId: _str(json['userId'] ?? json['user']),
      branchId: _str(json['branchId'] ?? json['branch']),
      month: _toInt(json['month']),
      year: _toInt(json['year']),
      employeeCode: _strOrDefault(json['employeeCode'], '--'),
      fullName: _strOrDefault(json['fullName'], '--'),
      branchName: _strOrDefault(json['branchName'], '--'),
      position: _strOrDefault(json['position'], '--'),
      hourlyRateSnapshot: _toDouble(json['hourlyRateSnapshot'] ?? json['hourlyRate']) ?? 0,
      totalHours: _toDouble(json['totalHours']) ?? 0,
      workingDays: _toInt(json['workingDays']) ?? 0,
      completedDays: _toInt(json['completedDays']) ?? 0,
      lateCount: _toInt(json['lateCount']) ?? 0,
      lateMinutes: _toInt(json['lateMinutes']) ?? 0,
      missingCheckoutDays:
          _toInt(json['missingCheckoutDays'] ?? json['missingCheckOutDays']) ?? 0,
      baseSalary: _toDouble(json['baseSalary']) ?? 0,
      heldCurrentAmount: _toDouble(json['heldCurrentAmount']) ?? 0,
      carryInHeldAmount: _toDouble(json['carryInHeldAmount']) ?? 0,
      totalPenalty: _toDouble(json['totalPenalty']) ?? 0,
      totalFixedDeduction: _toDouble(json['totalFixedDeduction']) ?? 0,
      totalOtherDeduction: _toDouble(json['totalOtherDeduction']) ?? 0,
      totalBonus: _toDouble(json['totalBonus']) ?? 0,
      totalDeductions: _toDouble(json['totalDeductions']) ?? 0,
      grossSalary: _toDouble(json['grossSalary']) ?? 0,
      payableAmount: _toDouble(json['payableAmount']) ?? 0,
      status: json['status']?.toString() ?? '',
      payDate: parseIsoDate(json['payDate']?.toString()),
      paidAt: parseIsoDate(json['paidAt']?.toString()),
      note: json['note']?.toString(),
    );
  }

  static Map<String, dynamic>? extractPayrollJson(dynamic data) {
    if (data == null) return null;
    if (data is! Map<String, dynamic>) return null;

    final payroll = data['payroll'];
    if (payroll is Map<String, dynamic>) return payroll;

    if (data.containsKey('payableAmount') ||
        data.containsKey('baseSalary') ||
        data.containsKey('employeeCode') ||
        data.containsKey('_id') ||
        data.containsKey('id')) {
      return data;
    }

    return null;
  }

  static String? _str(dynamic v) {
    if (v == null) return null;
    final s = v.toString();
    return s.isEmpty ? null : s;
  }

  static String _strOrDefault(dynamic v, String fallback) {
    final s = v?.toString().trim();
    if (s == null || s.isEmpty) return fallback;
    return s;
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
