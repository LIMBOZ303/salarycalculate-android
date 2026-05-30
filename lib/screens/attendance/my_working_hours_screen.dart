import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/format_date.dart';
import '../../core/utils/responsive.dart';
import '../../providers/attendance_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_button.dart';
import '../../widgets/attendance_history_item.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/stat_card.dart';
import 'attendance_history_screen.dart';

class MyWorkingHoursScreen extends StatefulWidget {
  const MyWorkingHoursScreen({super.key});

  @override
  State<MyWorkingHoursScreen> createState() => _MyWorkingHoursScreenState();
}

class _MyWorkingHoursScreenState extends State<MyWorkingHoursScreen> {
  late int _month;
  late int _year;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = now.month;
    _year = now.year;
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final provider = context.read<AttendanceProvider>();
    await provider.loadSummary(month: _month, year: _year);
    if (!mounted) return;
    await provider.loadHistory(month: _month, year: _year);
  }

  Future<void> _pickMonthYear() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(_year, _month),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _month = picked.month;
        _year = picked.year;
      });
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();
    final summary = provider.summary;
    final recent = provider.history.take(3).toList();
    final hPad = ResponsiveHelper.horizontalPadding(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: provider.isLoadingSummary && summary == null
            ? const LoadingWidget(message: 'Đang tải giờ làm...')
            : provider.summaryError != null && summary == null
                ? ErrorView(message: provider.summaryError!, onRetry: _load)
                : RefreshIndicator(
                    onRefresh: _load,
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
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Giờ làm của tôi',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: ResponsiveHelper.responsiveFont(context, 22),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: _pickMonthYear,
                                  icon: Icon(
                                    Icons.calendar_month,
                                    size: ResponsiveHelper.responsiveIconSize(context, 18),
                                  ),
                                  label: Text(
                                    monthYearLabel(_month, _year),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: ResponsiveHelper.verticalSpacing(context, 14)),
                            AppCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'THÁNG NÀY',
                                    style: TextStyle(
                                      fontSize: ResponsiveHelper.responsiveFont(context, 12),
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  SizedBox(height: ResponsiveHelper.verticalSpacing(context, 8)),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      formatHours(summary?.totalHours),
                                      style: TextStyle(
                                        fontSize: ResponsiveHelper.responsiveFont(context, 34),
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Tổng giờ làm tháng',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: ResponsiveHelper.responsiveFont(context, 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: ResponsiveHelper.verticalSpacing(context, 14)),
                            StatGrid(
                              children: [
                                StatCard(
                                  label: 'Ngày làm',
                                  value: '${summary?.totalDays ?? 0}',
                                  icon: Icons.event_available,
                                  accentColor: AppColors.success,
                                ),
                                StatCard(
                                  label: 'Đi trễ',
                                  value: '${summary?.lateCount ?? 0}',
                                  icon: Icons.warning_amber,
                                  accentColor: AppColors.warning,
                                ),
                                StatCard(
                                  label: 'Phút đi trễ',
                                  value: '${summary?.totalLateMinutes ?? 0}',
                                  icon: Icons.timer,
                                  accentColor: AppColors.danger,
                                ),
                                StatCard(
                                  label: 'Thiếu chấm ra',
                                  value: '${summary?.missingCheckOutDays ?? 0}',
                                  icon: Icons.logout,
                                  accentColor: AppColors.textSecondary,
                                ),
                              ],
                            ),
                            SizedBox(height: ResponsiveHelper.verticalSpacing(context, 20)),
                            const AppSectionTitle('Gần đây'),
                            if (provider.isLoadingHistory && recent.isEmpty)
                              Padding(
                                padding: EdgeInsets.all(ResponsiveHelper.verticalSpacing(context, 20)),
                                child: const Center(child: CircularProgressIndicator()),
                              )
                            else if (recent.isEmpty)
                              const EmptyState(
                                title: 'Chưa có lịch sử gần đây',
                                icon: Icons.history,
                              )
                            else
                              ...recent.map((e) => AttendanceHistoryItemWidget(item: e)),
                            SizedBox(height: ResponsiveHelper.verticalSpacing(context, 14)),
                            AppButton(
                              label: 'Xem lịch sử chấm công',
                              isOutlined: true,
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => AttendanceHistoryScreen(
                                      initialMonth: _month,
                                      initialYear: _year,
                                    ),
                                  ),
                                );
                              },
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
