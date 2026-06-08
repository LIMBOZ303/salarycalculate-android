import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/theme/app_decorations.dart';
import '../core/utils/format_date.dart';
import '../core/utils/responsive.dart';
import 'employee_avatar.dart';
import 'status_badge.dart';

/// Card tóm tắt profile: avatar + tên + chức vụ + badge + ngày gia nhập.
class ProfileSummaryCard extends StatelessWidget {
  const ProfileSummaryCard({
    super.key,
    required this.fullName,
    required this.position,
    required this.status,
    required this.statusLabel,
    this.avatarUrl,
    this.hireDate,
    this.onAvatarEdit,
    this.onAvatarDelete,
    this.isUploadingAvatar = false,
  });

  final String fullName;
  final String position;
  final String status;
  final String statusLabel;
  final String? avatarUrl;
  final DateTime? hireDate;
  final VoidCallback? onAvatarEdit;
  final VoidCallback? onAvatarDelete;
  final bool isUploadingAvatar;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.horizontalPadding(context),
        vertical: ResponsiveHelper.verticalSpacing(context, 20),
      ),
      decoration: AppDecorations.cardDecoration(
        radius: ResponsiveHelper.cardRadius(context),
      ),
      child: Column(
        children: [
          EmployeeAvatar(
            avatarUrl: avatarUrl,
            name: fullName,
            largeProfile: true,
            showBorder: true,
            showShadow: true,
          ),
          SizedBox(height: ResponsiveHelper.verticalSpacing(context, 14)),
          Text(
            safeDisplayText(fullName, fallback: 'Nhân viên'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ResponsiveHelper.responsiveFont(context, 20),
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveHelper.verticalSpacing(context, 4)),
          Text(
            safePosition(position),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ResponsiveHelper.responsiveFont(context, 14),
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: ResponsiveHelper.verticalSpacing(context, 10)),
          StatusBadge.fromStatus(status, customLabel: statusLabel),
          if (hireDate != null) ...[
            SizedBox(height: ResponsiveHelper.verticalSpacing(context, 8)),
            Text(
              'Gia nhập: ${formatDate(hireDate)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: ResponsiveHelper.responsiveFont(context, 13),
              ),
            ),
          ],
          if (onAvatarEdit != null) ...[
            SizedBox(height: ResponsiveHelper.verticalSpacing(context, 16)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isUploadingAvatar) ...[
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  const Text('Đang tải ảnh...'),
                ] else
                  TextButton.icon(
                    onPressed: onAvatarEdit,
                    icon: const Icon(Icons.camera_alt_outlined, size: 20),
                    label: const Text('Đổi ảnh'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                if (avatarUrl != null && avatarUrl!.isNotEmpty && onAvatarDelete != null && !isUploadingAvatar) ...[
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: onAvatarDelete,
                    icon: const Icon(Icons.delete_outline, size: 20),
                    label: const Text('Xóa ảnh'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
