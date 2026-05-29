import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/utils/format_date.dart';
import '../models/attendance_model.dart';

class AttendanceHistoryItemWidget extends StatelessWidget {
  const AttendanceHistoryItemWidget({super.key, required this.item});

  final AttendanceHistoryItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatDate(item.date),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
              _statusChip(),
            ],
          ),
          const SizedBox(height: 12),
          _infoRow(Icons.login, 'Vào', formatTime(item.checkInTime)),
          _infoRow(Icons.logout, 'Ra', formatTime(item.checkOutTime)),
          _infoRow(Icons.schedule, 'Tổng giờ', formatHours(item.totalHours)),
          if (item.lateMinutes > 0)
            _infoRow(Icons.warning_amber, 'Đi trễ', formatMinutes(item.lateMinutes)),
          if (item.suspicious == true) ...[
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.flag, size: 16, color: AppColors.warning),
                SizedBox(width: 6),
                Text(
                  'Có dấu hiệu bất thường',
                  style: TextStyle(color: AppColors.warning, fontSize: 13),
                ),
              ],
            ),
          ],
          if (item.note != null && item.note!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Ghi chú: ${item.note}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusChip() {
    Color color = AppColors.primary;
    if (item.status.toLowerCase() == 'late') color = AppColors.warning;
    if (item.status.toLowerCase() == 'completed') color = AppColors.success;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        item.statusLabel,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(color: AppColors.textSecondary)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
