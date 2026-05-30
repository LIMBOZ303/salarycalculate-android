import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

enum AttendanceStatusType {
  completed,
  checkedIn,
  late,
  notCheckedIn,
  active,
  pending,
  locked,
  error,
  unknown,
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.status,
    this.type,
  });

  final String label;
  final String? status;
  final AttendanceStatusType? type;

  factory StatusBadge.fromStatus(String status, {String? customLabel}) {
    final t = _resolveType(status);
    return StatusBadge(
      label: customLabel ?? _defaultLabel(t, status),
      type: t,
    );
  }

  static AttendanceStatusType _resolveType(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AttendanceStatusType.completed;
      case 'checked_in':
        return AttendanceStatusType.checkedIn;
      case 'late':
        return AttendanceStatusType.late;
      case 'not_checked_in':
      case '':
        return AttendanceStatusType.notCheckedIn;
      case 'active':
        return AttendanceStatusType.active;
      case 'pending':
        return AttendanceStatusType.pending;
      case 'locked':
      case 'inactive':
      case 'resigned':
      case 'rejected':
        return AttendanceStatusType.locked;
      case 'absent':
        return AttendanceStatusType.error;
      default:
        return AttendanceStatusType.unknown;
    }
  }

  static String _defaultLabel(AttendanceStatusType t, String status) {
    switch (t) {
      case AttendanceStatusType.completed:
        return 'Hoàn tất';
      case AttendanceStatusType.checkedIn:
        return 'Đang làm việc';
      case AttendanceStatusType.late:
        return 'Đi trễ';
      case AttendanceStatusType.notCheckedIn:
        return 'Chưa chấm công';
      case AttendanceStatusType.active:
        return 'Đang hoạt động';
      case AttendanceStatusType.pending:
        return 'Đang chờ duyệt';
      case AttendanceStatusType.locked:
        return 'Không hoạt động';
      case AttendanceStatusType.error:
        return 'Vắng';
      case AttendanceStatusType.unknown:
        return status.isEmpty ? '--' : status;
    }
  }

  Color get _bg {
    final t = type ?? (status != null ? _resolveType(status!) : AttendanceStatusType.unknown);
    switch (t) {
      case AttendanceStatusType.completed:
      case AttendanceStatusType.active:
        return AppColors.success.withValues(alpha: 0.12);
      case AttendanceStatusType.checkedIn:
      case AttendanceStatusType.late:
        return AppColors.warning.withValues(alpha: 0.15);
      case AttendanceStatusType.notCheckedIn:
        return AppColors.textSecondary.withValues(alpha: 0.12);
      case AttendanceStatusType.pending:
        return AppColors.lightBlue;
      case AttendanceStatusType.locked:
      case AttendanceStatusType.error:
        return AppColors.danger.withValues(alpha: 0.12);
      case AttendanceStatusType.unknown:
        return AppColors.lightBlue;
    }
  }

  Color get _fg {
    final t = type ?? (status != null ? _resolveType(status!) : AttendanceStatusType.unknown);
    switch (t) {
      case AttendanceStatusType.completed:
      case AttendanceStatusType.active:
        return AppColors.success;
      case AttendanceStatusType.checkedIn:
      case AttendanceStatusType.late:
        return AppColors.checkOut;
      case AttendanceStatusType.notCheckedIn:
        return AppColors.textSecondary;
      case AttendanceStatusType.pending:
        return AppColors.primary;
      case AttendanceStatusType.locked:
      case AttendanceStatusType.error:
        return AppColors.danger;
      case AttendanceStatusType.unknown:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: _fg,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
