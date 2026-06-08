import 'user_model.dart';

class BranchInfo {
  const BranchInfo({this.id, this.name, this.address});

  final String? id;
  final String? name;
  final String? address;

  factory BranchInfo.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      return const BranchInfo();
    }
    return BranchInfo(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      name: json['name']?.toString() ?? json['branchName']?.toString(),
      address: json['address']?.toString(),
    );
  }
}

class EmployeeModel {
  const EmployeeModel({
    required this.id,
    required this.employeeCode,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.position,
    required this.status,
    this.avatarUrl,
    this.branch,
    this.branchId,
    this.hourlyRate = 0,
    this.hireDate,
    this.user,
    this.userId,
  });

  final String id;
  final String employeeCode;
  final String fullName;
  final String email;
  final String phone;
  final String position;
  final String status;
  final String? avatarUrl;
  final BranchInfo? branch;
  final String? branchId;
  final double hourlyRate;
  final DateTime? hireDate;
  final UserModel? user;
  final String? userId;

  EmployeeModel copyWith({
    String? id,
    String? employeeCode,
    String? fullName,
    String? email,
    String? phone,
    String? position,
    String? status,
    String? avatarUrl,
    BranchInfo? branch,
    String? branchId,
    double? hourlyRate,
    DateTime? hireDate,
    UserModel? user,
    String? userId,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      employeeCode: employeeCode ?? this.employeeCode,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      position: position ?? this.position,
      status: status ?? this.status,
      avatarUrl: avatarUrl != null && avatarUrl.isEmpty ? '' : (avatarUrl ?? this.avatarUrl),
      branch: branch ?? this.branch,
      branchId: branchId ?? this.branchId,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      hireDate: hireDate ?? this.hireDate,
      user: user ?? this.user,
      userId: userId ?? this.userId,
    );
  }

  String get branchName => branch?.name ?? 'Chưa gán chi nhánh';

  String get branchAddress => branch?.address ?? '--';

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    final branchFromBranchKey = json['branch'];
    final branchFromId = json['branchId'];

    final branch = _parseBranch(branchFromId, branchFromBranchKey);
    final userId = _parseId(json['userId']);

    return EmployeeModel(
      id: _str(json['_id'] ?? json['id']),
      employeeCode: _str(json['employeeCode'] ?? json['code']),
      fullName: _str(
        json['fullName'] ??
            (userJson is Map ? userJson['fullName'] : null),
      ),
      email: _str(
        json['email'] ?? (userJson is Map ? userJson['email'] : null),
      ),
      phone: _str(
        json['phone'] ?? (userJson is Map ? userJson['phone'] : null),
      ),
      position: _str(json['position'] ?? json['jobTitle']),
      status: _str(
        json['status'] ?? (userJson is Map ? userJson['status'] : null),
        fallback: 'active',
      ),
      avatarUrl: _optionalStr(json['avatarUrl']) ??
          _optionalStr(json['avatar']) ??
          (userJson is Map ? _optionalStr(userJson['avatarUrl']) : null) ??
          (userJson is Map ? _optionalStr(userJson['avatar']) : null) ??
          (json['userId'] is Map ? _optionalStr(json['userId']['avatarUrl']) : null) ??
          (json['userId'] is Map ? _optionalStr(json['userId']['avatar']) : null),
      branch: branch,
      branchId: branch?.id ?? _optionalStr(branchFromId),
      hourlyRate: _toDouble(json['hourlyRate']) ?? 0,
      hireDate: _parseDate(
        json['hireDate'] ?? json['startDate'] ?? json['approvedAt'] ?? json['createdAt'],
      ),
      user: userJson is Map<String, dynamic> ? UserModel.fromJson(userJson) : null,
      userId: userId,
    );
  }

  static BranchInfo? _parseBranch(dynamic branchId, dynamic branch) {
    if (branchId is Map<String, dynamic>) {
      return BranchInfo(
        id: _str(branchId['_id'] ?? branchId['id']),
        name: _str(branchId['name']),
        address: _optionalStr(branchId['address']),
      );
    }
    if (branch is Map<String, dynamic>) {
      return BranchInfo.fromJson(branch);
    }
    if (branchId != null && branchId.toString().isNotEmpty) {
      return BranchInfo(id: branchId.toString());
    }
    return null;
  }

  static String? _parseId(dynamic value) {
    if (value == null) return null;
    if (value is Map) {
      return value['_id']?.toString() ?? value['id']?.toString();
    }
    return value.toString();
  }

  static String _str(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    final s = value.toString().trim();
    return s.isEmpty ? fallback : s;
  }

  static String? _optionalStr(dynamic value) {
    if (value == null) return null;
    final s = value.toString().trim();
    return s.isEmpty ? null : s;
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
