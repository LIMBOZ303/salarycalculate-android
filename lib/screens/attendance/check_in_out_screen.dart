import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/format_date.dart';
import '../../core/utils/responsive.dart';
import '../../models/attendance_model.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/employee_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/status_badge.dart';

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

    setState(() => _gpsStatus = ok ? 'Đang ở vị trí' : 'GPS thất bại');

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isCheckIn ? 'Chấm vào thành công' : 'Chấm ra thành công'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (provider.checkError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.checkError!),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final attendance = context.watch<AttendanceProvider>();
    final employee = context.watch<EmployeeProvider>().employee;
    final today = attendance.today ?? const TodayAttendanceModel();
    final isChecking = attendance.isChecking;
    final hPad = ResponsiveHelper.horizontalPadding(context);
    final btnSize = ResponsiveHelper.checkInButtonSize(context);

    final showCheckIn = today.canCheckIn && !today.isCompleted;
    final showCheckOut = today.canCheckOut;
    final isDone = today.isCompleted;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: attendance.isLoadingToday && attendance.today == null
            ? const LoadingWidget(message: 'Đang tải trạng thái...')
            : RefreshIndicator(
                onRefresh: () async {
                  await attendance.loadTodayAttendance();
                  if (!context.mounted) return;
                  await context.read<EmployeeProvider>().loadMyProfile(force: true);
                },
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    hPad,
                    ResponsiveHelper.verticalSpacing(context, 12),
                    hPad,
                    ResponsiveHelper.bottomNavPadding,
                  ),
                  child: ResponsiveHelper.constrainContent(
                    context,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Chấm công',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.responsiveFont(context, 22),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.verticalSpacing(context, 16)),
                        AppCard(
                          padding: EdgeInsets.symmetric(
                            vertical: ResponsiveHelper.verticalSpacing(context, 22),
                            horizontal: ResponsiveHelper.verticalSpacing(context, 16),
                          ),
                          child: Column(
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  formatTime(_now),
                                  style: TextStyle(
                                    fontSize: ResponsiveHelper.responsiveFont(context, 44),
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              SizedBox(height: ResponsiveHelper.verticalSpacing(context, 8)),
                              Text(
                                formatDateLong(_now),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.responsiveFont(context, 14),
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.verticalSpacing(context, 14)),
                        AppCard(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.lightBlue,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.location_on,
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
                                      safeBranchName(employee?.branchName),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: ResponsiveHelper.responsiveFont(context, 15),
                                      ),
                                    ),
                                    SizedBox(height: ResponsiveHelper.verticalSpacing(context, 6)),
                                    Text(
                                      safeAddress(employee?.branchAddress),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: ResponsiveHelper.responsiveFont(context, 13),
                                        height: 1.4,
                                      ),
                                    ),
                                    SizedBox(height: ResponsiveHelper.verticalSpacing(context, 8)),
                                    Row(
                                      children: [
                                        Icon(
                                          _gpsStatus.contains('Đang ở')
                                              ? Icons.check_circle
                                              : Icons.gps_fixed,
                                          size: 16,
                                          color: _gpsStatus.contains('thất bại')
                                              ? AppColors.danger
                                              : AppColors.success,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            'GPS: $_gpsStatus',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: ResponsiveHelper.responsiveFont(context, 13),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.verticalSpacing(context, 14)),
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Trạng thái hôm nay',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: ResponsiveHelper.responsiveFont(context, 15),
                                      ),
                                    ),
                                  ),
                                  Flexible(child: StatusBadge.fromStatus(today.status)),
                                ],
                              ),
                              SizedBox(height: ResponsiveHelper.verticalSpacing(context, 14)),
                              _statusRow(context, 'Giờ vào', formatTime(today.checkInTime)),
                              _statusRow(context, 'Giờ ra', formatTime(today.checkOutTime)),
                              _statusRow(context, 'Tổng giờ', formatHours(today.totalHours)),
                            ],
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.verticalSpacing(context, 24)),
                        if (isDone)
                          _buildCompletedState(context)
                        else if (showCheckIn)
                          _buildMainAction(
                            context,
                            label: 'CHẤM VÀO',
                            color: AppColors.success,
                            size: btnSize,
                            isLoading: isChecking,
                            onTap: () => _handleCheck(true),
                          )
                        else if (showCheckOut)
                          _buildMainAction(
                            context,
                            label: 'CHẤM RA',
                            color: AppColors.checkOut,
                            size: btnSize,
                            isLoading: isChecking,
                            onTap: () => _handleCheck(false),
                          )
                        else
                          const AppButton(
                            label: 'Không thể chấm công',
                            onPressed: null,
                          ),
                        SizedBox(height: ResponsiveHelper.verticalSpacing(context, 14)),
                        if (!isDone)
                          Text(
                            'Hệ thống sử dụng vị trí GPS để xác thực chấm công',
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: ResponsiveHelper.responsiveFont(context, 13),
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

  Widget _statusRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveHelper.verticalSpacing(context, 8)),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveHelper.verticalSpacing(context, 20)),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ResponsiveHelper.cardRadius(context)),
        border: Border.all(color: AppColors.success),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle,
            size: ResponsiveHelper.responsiveIconSize(context, 48),
            color: AppColors.success,
          ),
          SizedBox(height: ResponsiveHelper.verticalSpacing(context, 10)),
          Text(
            'Đã hoàn tất ca hôm nay',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: ResponsiveHelper.responsiveFont(context, 17),
              fontWeight: FontWeight.w700,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainAction(
    BuildContext context, {
    required String label,
    required Color color,
    required double size,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.fingerprint,
                        size: ResponsiveHelper.responsiveIconSize(context, 44),
                        color: Colors.white,
                      ),
                      SizedBox(height: ResponsiveHelper.verticalSpacing(context, 6)),
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: ResponsiveHelper.responsiveFont(context, 14),
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
