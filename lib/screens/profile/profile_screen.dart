import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/network/api_exception.dart';
import '../../services/avatar_service.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/employee_provider.dart';
import '../../providers/payroll_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_gradient_header.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/profile_info_item.dart';
import '../../widgets/profile_summary_card.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isUploadingAvatar = false;

  Future<void> _pickAndUploadAvatar() async {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Chọn từ thư viện'),
              onTap: () {
                Navigator.of(ctx).pop();
                _processUpload(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Chụp ảnh'),
              onTap: () {
                Navigator.of(ctx).pop();
                _processUpload(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processUpload(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile == null) return;
      if (!mounted) return;

      final avatarService = context.read<AvatarService>();
      final authProvider = context.read<AuthProvider>();
      final employeeProvider = context.read<EmployeeProvider>();

      setState(() => _isUploadingAvatar = true);

      final url = await avatarService.uploadMyAvatar(File(pickedFile.path));
      if (!mounted) return;

      authProvider.updateAvatarUrl(url);
      employeeProvider.updateAvatarUrl(url);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật ảnh đại diện thành công')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  Future<void> _deleteAvatar() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc muốn xóa ảnh đại diện?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    if (!mounted) return;

    final avatarService = context.read<AvatarService>();
    final authProvider = context.read<AuthProvider>();
    final employeeProvider = context.read<EmployeeProvider>();

    try {
      setState(() => _isUploadingAvatar = true);
      await avatarService.deleteMyAvatar();
      if (!mounted) return;

      authProvider.updateAvatarUrl('');
      employeeProvider.updateAvatarUrl('');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa ảnh đại diện')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

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
    context.read<PayrollProvider>().clear();
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
        return safeDisplayText(status);
    }
  }

  String _formatMoney(double rate) {
    if (rate <= 0) return '--';
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(rate)} VND/giờ';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmployeeProvider>();
    final employee = provider.employee;
    final hPad = ResponsiveHelper.horizontalPadding(context);
    final overlap = ResponsiveHelper.profileCardOverlap(context);

    if (provider.isLoading && employee == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(child: LoadingWidget(message: 'Đang tải hồ sơ...')),
      );
    }

    if (provider.error != null && employee == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(child: ErrorView(message: provider.error!, onRetry: _reload)),
      );
    }

    if (employee == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: EmptyState(
            title: 'Chưa có thông tin cá nhân',
            subtitle: provider.error,
            icon: Icons.person_off_outlined,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _reload,
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: ResponsiveHelper.constrainContent(
                  context,
                  Column(
                    children: [
                      const AppGradientHeader(
                        title: '',
                        variant: AppHeaderVariant.profileBanner,
                      ),
                      Transform.translate(
                        offset: Offset(0, -overlap),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: hPad),
                          child: ProfileSummaryCard(
                            fullName: employee.fullName,
                            position: employee.position,
                            status: employee.status,
                            statusLabel: _statusLabel(employee.status),
                            avatarUrl: employee.avatarUrl,
                            hireDate: employee.hireDate,
                            onAvatarEdit: _pickAndUploadAvatar,
                            onAvatarDelete: _deleteAvatar,
                            isUploadingAvatar: _isUploadingAvatar,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  hPad,
                  ResponsiveHelper.verticalSpacing(context, 8) - overlap,
                  hPad,
                  ResponsiveHelper.bottomNavPadding,
                ),
                sliver: SliverToBoxAdapter(
                  child: ResponsiveHelper.constrainContent(
                    context,
                    Column(
                      children: [
                        ProfileInfoCard(
                          title: 'Thông tin công việc',
                          icon: Icons.work_outline,
                          children: [
                            ProfileInfoItem(
                              icon: Icons.badge_outlined,
                              label: 'Mã nhân viên',
                              value: safeDisplayText(employee.employeeCode),
                            ),
                            ProfileInfoItem(
                              icon: Icons.business_center_outlined,
                              label: 'Chức vụ',
                              value: safePosition(employee.position),
                            ),
                            ProfileInfoItem(
                              icon: Icons.store_outlined,
                              label: 'Chi nhánh',
                              value: safeBranchName(employee.branchName),
                              maxLines: 2,
                            ),
                            ProfileInfoItem(
                              icon: Icons.payments_outlined,
                              label: 'Lương/giờ',
                              value: _formatMoney(employee.hourlyRate),
                            ),
                          ],
                        ),
                        ProfileInfoCard(
                          title: 'Thông tin cá nhân',
                          icon: Icons.person_outline,
                          children: [
                            ProfileInfoItem(
                              icon: Icons.phone_outlined,
                              label: 'Số điện thoại',
                              value: safeDisplayText(employee.phone),
                            ),
                            ProfileInfoItem(
                              icon: Icons.email_outlined,
                              label: 'Email',
                              value: safeDisplayText(employee.email),
                            ),
                            ProfileInfoItem(
                              icon: Icons.location_on_outlined,
                              label: 'Địa chỉ chi nhánh',
                              value: safeAddress(employee.branchAddress),
                              maxLines: 2,
                            ),
                            ProfileInfoItem(
                              icon: Icons.info_outline,
                              label: 'Trạng thái',
                              value: _statusLabel(employee.status),
                            ),
                          ],
                        ),
                        AppButton(
                          label: 'Đăng xuất',
                          variant: AppButtonVariant.danger,
                          icon: Icons.logout,
                          onPressed: _logout,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
