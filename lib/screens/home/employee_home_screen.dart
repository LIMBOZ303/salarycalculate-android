import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/format_date.dart';
import '../../core/utils/responsive.dart';
import '../../models/attendance_model.dart';
import '../../core/utils/format_money.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/employee_provider.dart';
import '../../providers/payroll_provider.dart';
import '../../widgets/payroll_status_badge.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_gradient_header.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';
import '../attendance/my_working_hours_screen.dart';

class EmployeeHomeScreen extends StatefulWidget {
  const EmployeeHomeScreen({
    super.key,
    this.onNavigateToCheckIn,
    this.onNavigateToPayroll,
  });

  final VoidCallback? onNavigateToCheckIn;
  final VoidCallback? onNavigateToPayroll;

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final now = DateTime.now();
    final employeeProvider = context.read<EmployeeProvider>();
    final attendanceProvider = context.read<AttendanceProvider>();
    final payrollProvider = context.read<PayrollProvider>();

    await employeeProvider.loadMyProfile(force: true);
    if (!mounted) return;

    await Future.wait([
      attendanceProvider.loadTodayAttendance(),
      attendanceProvider.loadSummary(month: now.month, year: now.year),
      payrollProvider.loadMyPayroll(now.month, now.year),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final employeeProvider = context.watch<EmployeeProvider>();
    final attendanceProvider = context.watch<AttendanceProvider>();
    final payrollProvider = context.watch<PayrollProvider>();
    final employee = employeeProvider.employee;
    final today = attendanceProvider.today ?? const TodayAttendanceModel();
    final summary = attendanceProvider.summary;
    final hPad = ResponsiveHelper.horizontalPadding(context);

    final isInitialLoading = (employeeProvider.isLoading && employee == null) ||
        (attendanceProvider.isLoadingToday && attendanceProvider.today == null);

    if (isInitialLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(child: LoadingWidget(message: 'Đang tải dữ liệu...')),
      );
    }

    if (employeeProvider.error != null && employee == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(child: ErrorView(message: employeeProvider.error!, onRetry: _load)),
      );
    }

    if (employee == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: EmptyState(
            title: 'Chưa có thông tin nhân viên',
            subtitle: employeeProvider.error,
            icon: Icons.person_off_outlined,
          ),
        ),
      );
    }

    final branchLine = safeBranchName(employee.branchName);
    final positionLine = safePosition(employee.position);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: ResponsiveHelper.constrainContent(
                  context,
                  AppGradientHeader(
                    subtitle: 'Xin chào,',
                    title: safeDisplayText(employee.fullName, fallback: 'Nhân viên'),
                    secondaryLine: '$positionLine · $branchLine',
                    avatarUrl: employee.avatarUrl,
                    avatarName: employee.fullName,
                    variant: AppHeaderVariant.home,
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  hPad,
                  0,
                  hPad,
                  ResponsiveHelper.bottomNavPadding,
                ),
                sliver: SliverToBoxAdapter(
                  child: ResponsiveHelper.constrainContent(
                    context,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Transform.translate(
                          offset: Offset(0, -ResponsiveHelper.verticalSpacing(context, 12)),
                          child: AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Trạng thái hôm nay',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: ResponsiveHelper.responsiveFont(context, 16),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: StatusBadge.fromStatus(today.status),
                                    ),
                                  ],
                                ),
                                if (attendanceProvider.isLoadingToday)
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: ResponsiveHelper.verticalSpacing(context, 16),
                                    ),
                                    child: const Center(child: CircularProgressIndicator()),
                                  )
                                else ...[
                                  SizedBox(height: ResponsiveHelper.verticalSpacing(context, 14)),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _timeBox(
                                          context,
                                          Icons.login,
                                          'Giờ vào',
                                          formatTime(today.checkInTime),
                                        ),
                                      ),
                                      SizedBox(width: ResponsiveHelper.verticalSpacing(context, 10)),
                                      Expanded(
                                        child: _timeBox(
                                          context,
                                          Icons.logout,
                                          'Giờ ra',
                                          formatTime(today.checkOutTime),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: ResponsiveHelper.verticalSpacing(context, 10)),
                                  _timeBox(
                                    context,
                                    Icons.schedule,
                                    'Tổng giờ hôm nay',
                                    formatHours(today.totalHours),
                                    fullWidth: true,
                                  ),
                                  SizedBox(height: ResponsiveHelper.verticalSpacing(context, 18)),
                                  AppButton(
                                    label: 'Chấm công ngay',
                                    icon: Icons.fingerprint,
                                    onPressed: () => widget.onNavigateToCheckIn?.call(),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.verticalSpacing(context, 8)),
                        AppCard(
                          onTap: widget.onNavigateToPayroll,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.lightBlue,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.account_balance_wallet_outlined,
                                  color: AppColors.primary,
                                  size: ResponsiveHelper.responsiveIconSize(context, 24),
                                ),
                              ),
                              SizedBox(width: ResponsiveHelper.verticalSpacing(context, 12)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Lương tháng này',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: ResponsiveHelper.responsiveFont(context, 15),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    if (payrollProvider.isLoading)
                                      Text(
                                        'Đang tải...',
                                        style: TextStyle(
                                          fontSize: ResponsiveHelper.responsiveFont(context, 13),
                                          color: AppColors.textSecondary,
                                        ),
                                      )
                                    else if (payrollProvider.payroll != null)
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              formatCurrency(payrollProvider.payroll!.payableAmount),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: ResponsiveHelper.responsiveFont(context, 16),
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          PayrollStatusBadge(status: payrollProvider.payroll!.status),
                                        ],
                                      )
                                    else
                                      Text(
                                        'Chưa có bảng lương',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: ResponsiveHelper.responsiveFont(context, 13),
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: AppColors.textSecondary,
                                size: ResponsiveHelper.responsiveIconSize(context, 22),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.verticalSpacing(context, 14)),
                        const AppSectionTitle('Thống kê tháng này'),
                        if (attendanceProvider.summaryError != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              attendanceProvider.summaryError!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: AppColors.danger, fontSize: 13),
                            ),
                          ),
                        StatGrid(
                          children: [
                            StatCard(
                              label: 'Tổng giờ làm',
                              value: formatHours(summary?.totalHours),
                              icon: Icons.schedule,
                            ),
                            StatCard(
                              label: 'Ngày làm',
                              value: '${summary?.totalDays ?? 0}',
                              icon: Icons.calendar_today,
                              accentColor: AppColors.success,
                            ),
                            StatCard(
                              label: 'Đi trễ',
                              value: '${summary?.lateCount ?? 0} lần',
                              icon: Icons.warning_amber,
                              accentColor: AppColors.warning,
                            ),
                            StatCard(
                              label: 'Phút đi trễ',
                              value: '${summary?.totalLateMinutes ?? 0}',
                              icon: Icons.timer,
                              accentColor: AppColors.danger,
                            ),
                          ],
                        ),
                        SizedBox(height: ResponsiveHelper.verticalSpacing(context, 14)),
                        AppButton(
                          label: 'Xem giờ làm chi tiết',
                          isOutlined: true,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const MyWorkingHoursScreen()),
                            );
                          },
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

  Widget _timeBox(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: EdgeInsets.all(ResponsiveHelper.isSmallPhone(context) ? 10 : 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: ResponsiveHelper.responsiveIconSize(context, 20), color: AppColors.primary),
          SizedBox(height: ResponsiveHelper.verticalSpacing(context, 6)),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: ResponsiveHelper.responsiveFont(context, 12),
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: ResponsiveHelper.responsiveFont(context, 16),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
