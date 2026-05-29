import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/format_date.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/employee_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/employee_avatar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_widget.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeProvider>().loadMyProfile(force: true);
    });
  }

  Future<void> _reload() async {
    await context.read<EmployeeProvider>().loadMyProfile(force: true);
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    context.read<EmployeeProvider>().clear();
    context.read<AttendanceProvider>().clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  String _statusLabel(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return 'Đang hoạt động';
      case 'pending':
        return 'Chờ duyệt';
      case 'locked':
        return 'Đã khóa';
      case 'inactive':
        return 'Ngưng hoạt động';
      default:
        return status ?? '--';
    }
  }

  String _formatMoney(double rate) {
    if (rate <= 0) return '--';
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(rate)} đ/giờ';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmployeeProvider>();
    final employee = provider.employee;

    if (provider.isLoading && employee == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: LoadingWidget(message: 'Đang tải hồ sơ...'),
      );
    }

    if (provider.error != null && employee == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: ErrorView(message: provider.error!, onRetry: _reload),
      );
    }

    if (employee == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: EmptyState(
          title: 'Chưa có thông tin cá nhân',
          subtitle: provider.error,
          icon: Icons.person_off_outlined,
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _reload,
          child: ListView(
            padding: const EdgeInsets.all(20),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Center(
                child: EmployeeAvatar(
                  avatarUrl: employee.avatar,
                  name: employee.fullName,
                  size: 96,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  employee.fullName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _tile('Mã nhân viên', employee.employeeCode),
              _tile('Số điện thoại', employee.phone),
              _tile('Email', employee.email),
              _tile('Chi nhánh', employee.branchName),
              _tile('Địa chỉ chi nhánh', employee.branchAddress),
              _tile('Chức vụ', employee.position),
              _tile('Lương/giờ', _formatMoney(employee.hourlyRate)),
              _tile('Ngày bắt đầu', formatDate(employee.hireDate)),
              _tile('Trạng thái', _statusLabel(employee.status)),
              const SizedBox(height: 32),
              AppButton(
                label: 'Đăng xuất',
                color: AppColors.danger,
                onPressed: _logout,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tile(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '--' : value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
