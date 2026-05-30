import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';
import 'pending_approval_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      fullName: _fullNameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đăng ký thành công. Tài khoản đang chờ admin duyệt.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const PendingApprovalScreen()),
        (_) => false,
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
    final fieldGap = ResponsiveHelper.isSmallPhone(context) ? 12.0 : 16.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            hPad,
            0,
            hPad,
            MediaQuery.viewInsetsOf(context).bottom + 24,
          ),
          child: ResponsiveHelper.constrainContent(
            context,
            Column(
              children: [
                Container(
                  padding: EdgeInsets.all(ResponsiveHelper.isSmallPhone(context) ? 12 : 14),
                  decoration: BoxDecoration(
                    color: AppColors.lightBlue,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.person_add,
                    size: ResponsiveHelper.responsiveIconSize(context, 30),
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.verticalSpacing(context, 14)),
                Text(
                  'Salary Calculate',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.responsiveFont(context, 20),
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.verticalSpacing(context, 20)),
                AppCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Tạo tài khoản mới',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.responsiveFont(context, 22),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.verticalSpacing(context, 8)),
                        Text(
                          'Tài khoản cần được admin duyệt trước khi sử dụng',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.4,
                            fontSize: ResponsiveHelper.responsiveFont(context, 14),
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.verticalSpacing(context, 20)),
                        AppTextField(
                          controller: _fullNameController,
                          label: 'Họ và tên',
                          prefixIcon: Icons.person_outline,
                          validator: (v) => Validators.required(v, field: 'Họ tên'),
                        ),
                        SizedBox(height: fieldGap),
                        AppTextField(
                          controller: _phoneController,
                          label: 'Số điện thoại',
                          hint: '0901234567',
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: Validators.phone,
                        ),
                        SizedBox(height: fieldGap),
                        AppTextField(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'email@congty.com',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email,
                        ),
                        SizedBox(height: fieldGap),
                        AppTextField(
                          controller: _passwordController,
                          label: 'Mật khẩu',
                          prefixIcon: Icons.lock_outline,
                          obscureText: true,
                          validator: Validators.password,
                        ),
                        SizedBox(height: fieldGap),
                        AppTextField(
                          controller: _confirmPasswordController,
                          label: 'Xác nhận mật khẩu',
                          prefixIcon: Icons.verified_user_outlined,
                          obscureText: true,
                          validator: (v) => Validators.confirmPassword(
                            v,
                            _passwordController.text,
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.verticalSpacing(context, 22)),
                        AppButton(
                          label: 'Đăng ký',
                          isLoading: auth.status == AuthStatus.loading,
                          onPressed: _register,
                        ),
                      ],
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Đã có tài khoản? Đăng nhập',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
