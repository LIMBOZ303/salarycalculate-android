import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/config/app_config.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/responsive.dart';

class EmployeeAvatar extends StatelessWidget {
  const EmployeeAvatar({
    super.key,
    this.avatarUrl,
    required this.name,
    this.size = 56,
    this.showBorder = false,
    this.showShadow = false,
    this.largeProfile = false,
  });

  final String? avatarUrl;
  final String name;
  final double size;
  final bool showBorder;
  final bool showShadow;
  final bool largeProfile;

  String? get _fullUrl {
    if (avatarUrl == null || avatarUrl!.isEmpty) return null;
    if (avatarUrl!.startsWith('http')) return avatarUrl;
    return '${AppConfig.baseUrl}$avatarUrl';
  }

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  static double profileSize(BuildContext context) {
    if (ResponsiveHelper.isSmallPhone(context)) return 80;
    if (ResponsiveHelper.isLargePhone(context)) return 104;
    if (ResponsiveHelper.isTablet(context)) return 112;
    return 92;
  }

  @override
  Widget build(BuildContext context) {
    final resolvedSize = largeProfile ? profileSize(context) : size;
    final url = _fullUrl;

    Widget avatar = Container(
      width: resolvedSize,
      height: resolvedSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.lightBlue,
        border: showBorder
            ? Border.all(color: Colors.white, width: 4)
            : null,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: AppColors.textPrimary.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ClipOval(
        child: url != null
            ? CachedNetworkImage(
                imageUrl: url,
                width: resolvedSize,
                height: resolvedSize,
                fit: BoxFit.cover,
                placeholder: (_, __) => _initialsWidget(resolvedSize),
                errorWidget: (_, __, ___) => _initialsWidget(resolvedSize),
              )
            : _initialsWidget(resolvedSize),
      ),
    );

    return avatar;
  }

  Widget _initialsWidget(double resolvedSize) {
    return Container(
      width: resolvedSize,
      height: resolvedSize,
      color: AppColors.lightBlue,
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: TextStyle(
          fontSize: resolvedSize * 0.34,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
