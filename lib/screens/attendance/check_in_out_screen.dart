import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/format_date.dart';
import '../../models/attendance_model.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/employee_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/loading_widget.dart';

class CheckInOutScreen extends StatefulWidget {
  const CheckInOutScreen({super.key});

  @override
  State<CheckInOutScreen> createState() => _CheckInOutScreenState();
}

class _CheckInOutScreenState extends State<CheckInOutScreen> {
  Timer? _clockTimer;
  DateTime _now = DateTime.now();
  String _gpsStatus = 'Chưa kiểm tra';

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceProvider>().loadTodayAttendance();
      context.read<EmployeeProvider>().loadMyProfile();
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleCheck(bool isCheckIn) async {
    setState(() => _gpsStatus = 'Đang lấy vị trí GPS...');

    final provider = context.read<AttendanceProvider>();
    final ok = isCheckIn ? await provider.checkIn() : await provider.checkOut();

    if (!mounted) return;

    setState(() => _gpsStatus = ok ? 'GPS đã gửi thành công' : 'GPS thất bại');

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isCheckIn ? 'Chấm vào thành công' : 'Chấm ra thành công'),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (provider.checkError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.checkError!), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final attendance = context.watch<AttendanceProvider>();
    final employee = context.watch<EmployeeProvider>().employee;
    final today = attendance.today ?? const TodayAttendanceModel();
    final isChecking = attendance.isChecking;

    final showCheckIn = today.canCheckIn && !today.isCompleted;
    final showCheckOut = today.canCheckOut;
    final isDone = today.isCompleted;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: attendance.isLoadingToday && attendance.today == null
            ? const LoadingWidget(message: 'Đang tải trạng thái...')
            : RefreshIndicator(
                onRefresh: () => attendance.loadTodayAttendance(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  children: [
                    Center(
                      child: Text(
                        formatTime(_now),
                        style: const TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        formatDate(_now),
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _infoCard(
                      'Nhân viên',
                      employee?.fullName ?? '--',
                    ),
                    const SizedBox(height: 10),
                    _infoCard('Chi nhánh', employee?.branchName ?? '--'),
                    const SizedBox(height: 10),
                    _infoCard('Trạng thái hôm nay', today.statusLabel),
                    const SizedBox(height: 10),
                    _infoCard('GPS', _gpsStatus),
                    const SizedBox(height: 32),
                    if (isDone)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.success),
                        ),
                        child: const Text(
                          'Bạn đã hoàn tất ca hôm nay.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                      )
                    else if (showCheckIn)
                      AppButton(
                        label: 'CHẤM VÀO',
                        height: 72,
                        color: AppColors.success,
                        isLoading: isChecking,
                        onPressed: isChecking ? null : () => _handleCheck(true),
                      )
                    else if (showCheckOut)
                      AppButton(
                        label: 'CHẤM RA',
                        height: 72,
                        color: AppColors.checkOut,
                        isLoading: isChecking,
                        onPressed: isChecking ? null : () => _handleCheck(false),
                      )
                    else
                      const AppButton(
                        label: 'Không thể chấm công',
                        onPressed: null,
                      ),
                    const SizedBox(height: 16),
                    if (!isDone)
                      const Text(
                        'Đảm bảo bật GPS và đứng trong khu vực cho phép.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _infoCard(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
