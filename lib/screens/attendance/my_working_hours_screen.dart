import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/format_date.dart';
import '../../providers/attendance_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/working_hour_card.dart';
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
    await context.read<AttendanceProvider>().loadSummary(month: _month, year: _year);
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Giờ làm'),
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _pickMonthYear,
            tooltip: 'Chọn tháng',
          ),
        ],
      ),
      body: provider.isLoadingSummary && summary == null
          ? const LoadingWidget()
          : provider.summaryError != null && summary == null
              ? ErrorView(message: provider.summaryError!, onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Text(
                        monthYearLabel(_month, _year),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          WorkingHourCard(
                            label: 'Tổng giờ tháng',
                            value: formatHours(summary?.totalHours),
                            icon: Icons.schedule,
                          ),
                          const SizedBox(width: 10),
                          WorkingHourCard(
                            label: 'Ngày làm',
                            value: '${summary?.totalDays ?? 0}',
                            icon: Icons.event_available,
                            accentColor: AppColors.success,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          WorkingHourCard(
                            label: 'Lần đi trễ',
                            value: '${summary?.lateCount ?? 0}',
                            icon: Icons.warning_amber,
                            accentColor: AppColors.warning,
                          ),
                          const SizedBox(width: 10),
                          WorkingHourCard(
                            label: 'Phút đi trễ',
                            value: '${summary?.totalLateMinutes ?? 0}',
                            icon: Icons.timer,
                            accentColor: AppColors.danger,
                          ),
                        ],
                      ),
                      if ((summary?.missingCheckOutDays ?? 0) > 0) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.warning),
                          ),
                          child: Text(
                            'Thiếu chấm ra: ${summary!.missingCheckOutDays} ngày',
                            style: const TextStyle(color: AppColors.warning),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
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
    );
  }
}
