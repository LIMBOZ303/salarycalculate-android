import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/config/app_config.dart';
import '../core/constants/app_colors.dart';

class EmployeeAvatar extends StatelessWidget {
  const EmployeeAvatar({
    super.key,
    this.avatarUrl,
    required this.name,
    this.size = 56,
  });

  final String? avatarUrl;
  final String name;
  final double size;

  String? get _fullUrl {
    if (avatarUrl == null || avatarUrl!.isEmpty) return null;
    if (avatarUrl!.startsWith('http')) return avatarUrl;
    return '${AppConfig.baseUrl}$avatarUrl';
  }

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final url = _fullUrl;
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
      child: url != null
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: url,
                width: size,
                height: size,
                fit: BoxFit.cover,
                placeholder: (_, __) => _initialsWidget(),
                errorWidget: (_, __, ___) => _initialsWidget(),
              ),
            )
          : _initialsWidget(),
    );
  }

  Widget _initialsWidget() {
    return Text(
      _initials,
      style: TextStyle(
        fontSize: size * 0.35,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }
}
