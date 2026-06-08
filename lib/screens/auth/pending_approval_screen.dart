import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_badge.dart';
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
        const SnackBar(
          content: Text('Tài khoản vẫn đang chờ duyệt'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (auth.status == AuthStatus.sessionError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Không thể kiểm tra trạng thái. Vui lòng thử lại.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
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
    final hPad = ResponsiveHelper.horizontalPadding(context);
    final iconSize = ResponsiveHelper.responsiveIconSize(context, 64);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(hPad),
          child: ResponsiveHelper.constrainContent(
            context,
            ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.sizeOf(context).height -
                    MediaQuery.paddingOf(context).vertical -
                    hPad * 2,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(ResponsiveHelper.verticalSpacing(context, 24)),
                    decoration: const BoxDecoration(
                      color: AppColors.lightBlue,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.hourglass_top_rounded,
                      size: iconSize,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.verticalSpacing(context, 24)),
                  Text(
                    'Tài khoản đang chờ duyệt',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.responsiveFont(context, 22),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.verticalSpacing(context, 12)),
                  const StatusBadge(
                    label: 'Đang chờ duyệt',
                    type: AttendanceStatusType.pending,
                  ),
                  SizedBox(height: ResponsiveHelper.verticalSpacing(context, 18)),
                  const AppCard(
                    child: Text(
                      'Admin cần duyệt tài khoản của bạn trước khi bạn có thể chấm công. '
                      'Quá trình này thường diễn ra trong vòng 24 giờ làm việc.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.verticalSpacing(context, 28)),
                  AppButton(
                    label: 'Kiểm tra lại trạng thái',
                    icon: Icons.refresh,
                    isLoading: isLoading,
                    onPressed: isLoading ? null : () => _checkStatus(context),
                  ),
                  SizedBox(height: ResponsiveHelper.verticalSpacing(context, 12)),
                  AppButton(
                    label: 'Đăng xuất',
                    isOutlined: true,
                    onPressed: () => _logout(context),
                  ),
                  SizedBox(height: ResponsiveHelper.verticalSpacing(context, 16)),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline, size: 16, color: AppColors.textSecondary),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Cần hỗ trợ? Liên hệ bộ phận Nhân sự',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
