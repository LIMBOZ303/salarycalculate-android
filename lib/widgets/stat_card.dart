import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/theme/app_decorations.dart';
import '../core/utils/responsive.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.accentColor,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.primary;
    final pad = ResponsiveHelper.isSmallPhone(context) ? 12.0 : 16.0;

    return Container(
      padding: EdgeInsets.all(pad),
      decoration: AppDecorations.cardDecoration(
        radius: ResponsiveHelper.cardRadius(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: ResponsiveHelper.responsiveIconSize(context, 22),
              ),
            ),
            SizedBox(height: ResponsiveHelper.verticalSpacing(context, 10)),
          ],
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: ResponsiveHelper.responsiveFont(context, 20),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: ResponsiveHelper.responsiveFont(context, 12),
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class StatGrid extends StatelessWidget {
  const StatGrid({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: ResponsiveHelper.statGridCrossAxisCount(context),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: ResponsiveHelper.verticalSpacing(context, 12),
      crossAxisSpacing: ResponsiveHelper.verticalSpacing(context, 12),
      childAspectRatio: ResponsiveHelper.statGridAspectRatio(context),
      children: children,
    );
  }
}
