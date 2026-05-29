import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../main/main_shell.dart';
import 'login_screen.dart';

class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key});

  Future<void> _checkStatus(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    await auth.refreshStatus();
    if (!context.mounted) return;

    if (auth.status == AuthStatus.authenticated) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } else if (auth.status == AuthStatus.pending) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tài khoản vẫn đang chờ duyệt')),
      );
    } else {
      await auth.logout();
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => LoginScreen(initialError: auth.errorMessage),
        ),
        (_) => false,
      );
    }
  }

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isLoading = auth.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.hourglass_top, size: 80, color: AppColors.warning),
              const SizedBox(height: 24),
              const Text(
                'Chờ duyệt tài khoản',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Tài khoản của bạn đang chờ admin duyệt.\n'
                'Bạn chưa thể chấm công cho đến khi được kích hoạt.',
                style: TextStyle(color: AppColors.textSecondary, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              AppButton(
                label: 'Kiểm tra lại trạng thái',
                isLoading: isLoading,
                onPressed: isLoading ? null : () => _checkStatus(context),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Đăng xuất',
                isOutlined: true,
                onPressed: () => _logout(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
