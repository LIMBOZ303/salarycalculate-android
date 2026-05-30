import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/utils/responsive.dart';
import 'employee_avatar.dart';

/// Variant header gradient.
enum AppHeaderVariant {
  /// Home: text trái, avatar nhỏ phải.
  home,

  /// Profile: chỉ nền gradient gọn, không nội dung.
  profileBanner,
}

class AppGradientHeader extends StatelessWidget {
  const AppGradientHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.secondaryLine,
    this.avatarUrl,
    this.avatarName,
    this.trailing,
    this.variant = AppHeaderVariant.home,
  });

  final String title;
  final String? subtitle;
  final String? secondaryLine;
  final String? avatarUrl;
  final String? avatarName;
  final Widget? trailing;
  final AppHeaderVariant variant;

  @override
  Widget build(BuildContext context) {
    final hPad = ResponsiveHelper.horizontalPadding(context);
    final radius = ResponsiveHelper.cardRadius(context) + 4;

    if (variant == AppHeaderVariant.profileBanner) {
      final bannerH = ResponsiveHelper.profileBannerHeight(context);
      return Container(
        width: double.infinity,
        height: bannerH,
        decoration: BoxDecoration(
          gradient: AppColors.headerGradient,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(radius),
            bottomRight: Radius.circular(radius),
          ),
        ),
      );
    }

    // Home header: nội dung gọn, avatar bên phải
    final avatarSize = ResponsiveHelper.avatarSize(context);
    final bottomPad = ResponsiveHelper.verticalSpacing(context, 16);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(radius),
          bottomRight: Radius.circular(radius),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(hPad, 8, hPad, bottomPad),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (subtitle != null) ...[
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.responsiveFont(context, 14),
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    safeDisplayText(title, fallback: 'Nhân viên'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.responsiveFont(context, 22),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (secondaryLine != null && secondaryLine!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      secondaryLine!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.responsiveFont(context, 13),
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 12),
              trailing!,
            ] else if (avatarName != null && avatarName!.isNotEmpty) ...[
              const SizedBox(width: 12),
              EmployeeAvatar(
                avatarUrl: avatarUrl,
                name: avatarName!,
                size: avatarSize,
                showBorder: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
