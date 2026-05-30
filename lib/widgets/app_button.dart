import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/theme/app_decorations.dart';
import '../core/utils/responsive.dart';

enum AppButtonVariant { primary, secondary, danger, success, checkOut }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.variant,
    this.color,
    this.textColor,
    this.height,
    this.icon,
    this.borderRadius,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final AppButtonVariant? variant;
  final Color? color;
  final Color? textColor;
  final double? height;
  final IconData? icon;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final bg = color ?? _bgColor;
    final fg = textColor ?? (isOutlined ? bg : Colors.white);
    final radius = borderRadius ?? AppDecorations.buttonRadius;
    final h = height ?? ResponsiveHelper.buttonHeight(context);

    if (isOutlined || variant == AppButtonVariant.secondary) {
      return SizedBox(
        width: double.infinity,
        height: h,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: bg, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
            foregroundColor: bg,
          ),
          child: _child(bg),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: h,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          disabledBackgroundColor: bg.withValues(alpha: 0.45),
          elevation: variant == AppButtonVariant.primary ? 2 : 0,
          shadowColor: bg.withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        ),
        child: _child(fg),
      ),
    );
  }

  Color get _bgColor {
    if (color != null) return color!;
    switch (variant) {
      case AppButtonVariant.danger:
        return AppColors.danger;
      case AppButtonVariant.success:
        return AppColors.success;
      case AppButtonVariant.checkOut:
        return AppColors.checkOut;
      case AppButtonVariant.secondary:
        return AppColors.primary;
      case AppButtonVariant.primary:
      case null:
        return AppColors.primary;
    }
  }

  Widget _child(Color color) {
    if (isLoading) {
      return SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(strokeWidth: 2, color: color),
      );
    }
    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      );
    }
    return Text(
      label,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color),
    );
  }
}
