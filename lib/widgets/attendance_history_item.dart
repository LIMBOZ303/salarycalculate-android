import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/utils/format_date.dart';
import '../core/utils/responsive.dart';
import '../models/attendance_model.dart';
import 'status_badge.dart';

class AttendanceHistoryItemWidget extends StatelessWidget {
  const AttendanceHistoryItemWidget({super.key, required this.item});

  final AttendanceHistoryItem item;

  Color get _accentColor {
    switch (item.status.toLowerCase()) {
      case 'late':
        return AppColors.warning;
      case 'completed':
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final narrow = ResponsiveHelper.isSmallPhone(context);

    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveHelper.verticalSpacing(context, 12)),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(ResponsiveHelper.cardRadius(context)),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: _accentColor,
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(ResponsiveHelper.cardRadius(context)),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(ResponsiveHelper.isSmallPhone(context) ? 12 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: ResponsiveHelper.responsiveIconSize(context, 18),
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            formatDate(item.date),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: ResponsiveHelper.responsiveFont(context, 15),
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Flexible(
                          child: StatusBadge.fromStatus(
                            item.status,
                            customLabel: item.statusLabel,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: ResponsiveHelper.verticalSpacing(context, 12)),
                    if (narrow)
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          _timeChip(Icons.login, 'Vào', formatTime(item.checkInTime)),
                          _timeChip(Icons.logout, 'Ra', formatTime(item.checkOutTime)),
                          _timeChip(Icons.schedule, 'Tổng', formatHours(item.totalHours), highlight: true),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(child: _timeCell(Icons.login, 'Giờ vào', formatTime(item.checkInTime))),
                          Expanded(child: _timeCell(Icons.logout, 'Giờ ra', formatTime(item.checkOutTime))),
                          Expanded(
                            child: _timeCell(
                              Icons.schedule,
                              'Tổng giờ',
                              formatHours(item.totalHours),
                              highlight: true,
                            ),
                          ),
                        ],
                      ),
                    if (item.lateMinutes > 0) ...[
                      SizedBox(height: ResponsiveHelper.verticalSpacing(context, 8)),
                      Row(
                        children: [
                          const Icon(Icons.warning_amber, size: 16, color: AppColors.warning),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Đi trễ ${formatMinutes(item.lateMinutes)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.warning,
                                fontSize: ResponsiveHelper.responsiveFont(context, 13),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeCell(IconData icon, String label, String value, {bool highlight = false}) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(height: 4),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: highlight ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _timeChip(IconData icon, String label, String value, {bool highlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            '$label: $value',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: highlight ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
