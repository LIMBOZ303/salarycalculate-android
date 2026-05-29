import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/utils/format_date.dart';
import '../models/attendance_model.dart';

class AttendanceStatusCard extends StatelessWidget {
  const AttendanceStatusCard({super.key, required this.attendance});

  final TodayAttendanceModel attendance;

  Color _statusColor() {
    switch (attendance.status.toLowerCase()) {
      case 'completed':
        return AppColors.success;
      case 'late':
        return AppColors.warning;
      case 'checked_in':
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _statusColor(),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                attendance.statusLabel,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _row('Giờ vào', formatTime(attendance.checkInTime)),
          const SizedBox(height: 8),
          _row('Giờ ra', formatTime(attendance.checkOutTime)),
          const SizedBox(height: 8),
          _row('Tổng giờ', formatHours(attendance.totalHours)),
          if (attendance.lateMinutes > 0) ...[
            const SizedBox(height: 8),
            _row('Đi trễ', formatMinutes(attendance.lateMinutes)),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
