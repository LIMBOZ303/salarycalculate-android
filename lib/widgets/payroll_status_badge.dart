import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class PayrollStatusBadge extends StatelessWidget {
  const PayrollStatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    Color bg;
    Color fg;
    String label;

    switch (normalized) {
      case 'draft':
        label = 'Nháp';
        bg = AppColors.textSecondary.withValues(alpha: 0.12);
        fg = AppColors.textSecondary;
        break;
      case 'confirmed':
        label = 'Đã chốt';
        bg = AppColors.lightBlue;
        fg = AppColors.primary;
        break;
      case 'paid':
        label = 'Đã thanh toán';
        bg = AppColors.success.withValues(alpha: 0.12);
        fg = AppColors.success;
        break;
      default:
        label = status.isEmpty ? '--' : status;
        bg = AppColors.lightBlue;
        fg = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
