import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/format_date.dart';
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Lịch sử chấm công'),
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: _pickMonthYear),
        ],
      ),
      body: provider.isLoadingHistory
          ? const LoadingWidget()
          : provider.historyError != null
              ? ErrorView(message: provider.historyError!, onRetry: _load)
              : provider.history.isEmpty
                  ? EmptyState(
                      title: 'Chưa có lịch sử chấm công.',
                      subtitle: monthYearLabel(_month, _year),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.history.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                monthYearLabel(_month, _year),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }
                          final item = provider.history[index - 1];
                          return AttendanceHistoryItemWidget(item: item);
                        },
                      ),
                    ),
    );
  }
}
