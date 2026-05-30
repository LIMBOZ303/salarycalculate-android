import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppDecorations {
  AppDecorations._();

  static const double cardRadius = 20;
  static const double buttonRadius = 14;

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: AppColors.textPrimary.withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static BoxDecoration cardDecoration({Color? color, double radius = cardRadius}) => BoxDecoration(
        color: color ?? AppColors.card,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: cardShadow,
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      );
}
