import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/format_date.dart';
import '../../models/attendance_model.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/employee_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/attendance_status_card.dart';
import '../../widgets/employee_avatar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/working_hour_card.dart';
import '../attendance/my_working_hours_screen.dart';

class EmployeeHomeScreen extends StatefulWidget {
  const EmployeeHomeScreen({super.key, this.onNavigateToCheckIn});

  final VoidCallback? onNavigateToCheckIn;

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

    await employeeProvider.loadMyProfile(force: true);
    if (!mounted) return;

    await Future.wait([
      attendanceProvider.loadTodayAttendance(),
      attendanceProvider.loadSummary(month: now.month, year: now.year),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final employeeProvider = context.watch<EmployeeProvider>();
    final attendanceProvider = context.watch<AttendanceProvider>();
    final employee = employeeProvider.employee;
    final today = attendanceProvider.today ?? const TodayAttendanceModel();
    final summary = attendanceProvider.summary;

    final isInitialLoading = (employeeProvider.isLoading && employee == null) ||
        (attendanceProvider.isLoadingToday && attendanceProvider.today == null);

    if (isInitialLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: LoadingWidget(message: 'Đang tải dữ liệu...'),
      );
    }

    if (employeeProvider.error != null && employee == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: ErrorView(message: employeeProvider.error!, onRetry: _load),
      );
    }

    if (employee == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: EmptyState(
          title: 'Chưa có thông tin nhân viên',
          subtitle: employeeProvider.error,
          icon: Icons.person_off_outlined,
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Row(
              children: [
                EmployeeAvatar(
                  avatarUrl: employee.avatar,
                  name: employee.fullName,
                  size: 64,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Xin chào,',
                        style: TextStyle(
                          color: AppColors.textSecondary.withValues(alpha: 0.9),
                        ),
                      ),
                      Text(
                        employee.fullName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        employee.position,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      Text(
                        employee.branchName,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Hôm nay',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            if (attendanceProvider.todayError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  attendanceProvider.todayError!,
                  style: const TextStyle(color: AppColors.danger, fontSize: 13),
                ),
              ),
            if (attendanceProvider.isLoadingToday)
              const LoadingWidget()
            else
              AttendanceStatusCard(attendance: today),
            const SizedBox(height: 20),
            const Text(
              'Tháng này',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            if (attendanceProvider.summaryError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  attendanceProvider.summaryError!,
                  style: const TextStyle(color: AppColors.danger, fontSize: 13),
                ),
              ),
            Row(
              children: [
                WorkingHourCard(
                  label: 'Tổng giờ',
                  value: formatHours(summary?.totalHours),
                  icon: Icons.schedule,
                ),
                const SizedBox(width: 10),
                WorkingHourCard(
                  label: 'Ngày làm',
                  value: '${summary?.totalDays ?? 0}',
                  icon: Icons.calendar_today,
                  accentColor: AppColors.success,
                ),
                const SizedBox(width: 10),
                WorkingHourCard(
                  label: 'Đi trễ',
                  value: '${summary?.lateCount ?? 0}',
                  icon: Icons.warning_amber,
                  accentColor: AppColors.warning,
                ),
              ],
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Chấm công ngay',
              onPressed: () => widget.onNavigateToCheckIn?.call(),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Xem giờ làm',
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
    );
  }
}
