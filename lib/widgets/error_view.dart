import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import 'app_button.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: AppColors.danger),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              AppButton(
                label: 'Thử lại',
                onPressed: onRetry,
                isOutlined: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
