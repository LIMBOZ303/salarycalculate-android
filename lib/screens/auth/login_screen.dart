import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';
import '../main/main_shell.dart';
import 'pending_approval_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.initialError});

  final String? initialError;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.initialError!),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final ok = await auth.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;

    if (ok && auth.status == AuthStatus.authenticated) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } else if (ok && auth.status == AuthStatus.pending) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PendingApprovalScreen()),
      );
    } else if (auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage!),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final hPad = ResponsiveHelper.horizontalPadding(context);
    final headerH = ResponsiveHelper.loginHeaderHeight(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(hPad, 24, hPad, headerH * 0.35),
                      height: headerH,
                      decoration: const BoxDecoration(
                        gradient: AppColors.headerGradient,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(
                              ResponsiveHelper.isSmallPhone(context) ? 12 : 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.access_time,
                              size: ResponsiveHelper.responsiveIconSize(context, 36),
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: ResponsiveHelper.verticalSpacing(context, 12)),
                          Text(
                            'Salary Calculate',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: ResponsiveHelper.responsiveFont(context, 22),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(0, -ResponsiveHelper.verticalSpacing(context, 40)),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: hPad),
                        child: ResponsiveHelper.constrainContent(
                          context,
                          AppCard(
                            padding: EdgeInsets.all(ResponsiveHelper.verticalSpacing(context, 22)),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Chào mừng trở lại',
                                    style: TextStyle(
                                      fontSize: ResponsiveHelper.responsiveFont(context, 22),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: ResponsiveHelper.verticalSpacing(context, 8)),
                                  Text(
                                    'Đăng nhập để chấm công hôm nay',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: ResponsiveHelper.responsiveFont(context, 14),
                                    ),
                                  ),
                                  SizedBox(height: ResponsiveHelper.verticalSpacing(context, 20)),
                                  AppTextField(
                                    controller: _emailController,
                                    label: 'Email',
                                    hint: 'email@congty.com',
                                    prefixIcon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: Validators.email,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  SizedBox(height: ResponsiveHelper.verticalSpacing(context, 14)),
                                  AppTextField(
                                    controller: _passwordController,
                                    label: 'Mật khẩu',
                                    hint: '••••••••',
                                    prefixIcon: Icons.lock_outline,
                                    obscureText: true,
                                    validator: Validators.password,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => _login(),
                                  ),
                                  SizedBox(height: ResponsiveHelper.verticalSpacing(context, 22)),
                                  AppButton(
                                    label: 'Đăng nhập',
                                    icon: Icons.login,
                                    isLoading: auth.status == AuthStatus.loading,
                                    onPressed: _login,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 24),
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                          );
                        },
                        child: Text(
                          'Chưa có tài khoản? Đăng ký tài khoản',
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.responsiveFont(context, 14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
