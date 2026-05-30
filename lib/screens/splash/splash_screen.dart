import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../auth/pending_approval_screen.dart';
import '../main/main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final auth = context.read<AuthProvider>();
    await auth.checkSession();
    if (!mounted) return;

    switch (auth.status) {
      case AuthStatus.authenticated:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainShell()),
        );
        break;
      case AuthStatus.pending:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const PendingApprovalScreen()),
        );
        break;
      case AuthStatus.error:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => LoginScreen(initialError: auth.errorMessage),
          ),
        );
        break;
      default:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconSize = ResponsiveHelper.responsiveIconSize(context, 72);
    final titleSize = ResponsiveHelper.responsiveFont(context, 26);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(ResponsiveHelper.horizontalPadding(context)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(ResponsiveHelper.verticalSpacing(context, 22)),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.cardRadius(context),
                      ),
                    ),
                    child: Icon(
                      Icons.access_time_filled_rounded,
                      size: iconSize,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.verticalSpacing(context, 22)),
                  Text(
                    'Salary Calculate',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.verticalSpacing(context, 8)),
                  Text(
                    'Chấm công nhân viên',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.responsiveFont(context, 15),
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.verticalSpacing(context, 36)),
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.verticalSpacing(context, 14)),
                  Text(
                    'Đang tải dữ liệu...',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.responsiveFont(context, 13),
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
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
