import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/format_date.dart';
import '../../core/utils/responsive.dart';
import '../../providers/attendance_provider.dart';
import '../../widgets/attendance_history_item.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_widget.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({
    super.key,
    this.initialMonth,
    this.initialYear,
  });

  final int? initialMonth;
  final int? initialYear;

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  late int _month;
  late int _year;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = widget.initialMonth ?? now.month;
    _year = widget.initialYear ?? now.year;
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    await context.read<AttendanceProvider>().loadHistory(
          month: _month,
          year: _year,
        );
    if (!mounted) return;
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
    final hPad = ResponsiveHelper.horizontalPadding(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Lịch sử chấm công'),
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _pickMonthYear,
            tooltip: 'Chọn tháng',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: provider.isLoadingHistory ? null : _load,
          ),
        ],
      ),
      body: SafeArea(
        child: provider.isLoadingHistory && provider.history.isEmpty
            ? const LoadingWidget(message: 'Đang tải lịch sử...')
            : provider.historyError != null && provider.history.isEmpty
                ? ErrorView(message: provider.historyError!, onRetry: _load)
                : provider.history.isEmpty
                    ? EmptyState(
                        title: 'Chưa có lịch sử chấm công.',
                        subtitle: monthYearLabel(_month, _year),
                        icon: Icons.history,
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        color: AppColors.primary,
                        child: ListView.builder(
                          padding: EdgeInsets.fromLTRB(
                            hPad,
                            ResponsiveHelper.verticalSpacing(context, 12),
                            hPad,
                            ResponsiveHelper.verticalSpacing(context, 24),
                          ),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: provider.history.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return ResponsiveHelper.constrainContent(
                                context,
                                Padding(
                                  padding: EdgeInsets.only(
                                    bottom: ResponsiveHelper.verticalSpacing(context, 14),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        monthYearLabel(_month, _year),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: ResponsiveHelper.responsiveFont(context, 18),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Theo dõi thời gian ra vào và trạng thái điểm danh',
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
                              );
                            }
                            final item = provider.history[index - 1];
                            return ResponsiveHelper.constrainContent(
                              context,
                              AttendanceHistoryItemWidget(item: item),
                            );
                          },
                        ),
                      ),
      ),
    );
  }
}
