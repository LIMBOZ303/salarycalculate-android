import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/format_date.dart';
import '../../core/utils/format_money.dart';
import '../../core/utils/responsive.dart';
import '../../models/payroll_model.dart';
import '../../providers/payroll_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_gradient_header.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/payroll_status_badge.dart';
import '../../widgets/stat_card.dart';

class MyPayrollScreen extends StatefulWidget {
  const MyPayrollScreen({super.key});

  @override
  State<MyPayrollScreen> createState() => _MyPayrollScreenState();
}

class _MyPayrollScreenState extends State<MyPayrollScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final provider = context.read<PayrollProvider>();
    await provider.loadMyPayroll(provider.selectedMonth, provider.selectedYear);
  }

  Future<void> _pickMonthYear() async {
    final provider = context.read<PayrollProvider>();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(provider.selectedYear, provider.selectedMonth),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      provider.setMonthYear(picked.month, picked.year);
      await provider.loadMyPayroll(picked.month, picked.year);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PayrollProvider>();
    final hPad = ResponsiveHelper.horizontalPadding(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: provider.isLoading && provider.payroll == null && provider.error == null
            ? const LoadingWidget(message: 'Đang tải bảng lương...')
            : provider.error != null && provider.payroll == null
                ? ErrorView(message: provider.error!, onRetry: _load)
                : RefreshIndicator(
                    onRefresh: _load,
                    color: AppColors.primary,
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: ResponsiveHelper.constrainContent(
                            context,
                            const AppGradientHeader(
                              title: 'Lương của tôi',
                              secondaryLine: 'Theo dõi lương và trạng thái thanh toán',
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            hPad,
                            ResponsiveHelper.verticalSpacing(context, 12),
                            hPad,
                            ResponsiveHelper.bottomNavPadding,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: ResponsiveHelper.constrainContent(
                              context,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _MonthYearSelector(
                                    month: provider.selectedMonth,
                                    year: provider.selectedYear,
                                    onTap: _pickMonthYear,
                                  ),
                                  SizedBox(height: ResponsiveHelper.verticalSpacing(context, 14)),
                                  if (provider.isLoading && provider.payroll == null)
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: ResponsiveHelper.verticalSpacing(context, 32),
                                      ),
                                      child: const Center(child: CircularProgressIndicator()),
                                    )
                                  else if (provider.payroll == null)
                                    EmptyState(
                                      title: 'Chưa có bảng lương cho tháng này',
                                      subtitle:
                                          'Bảng lương sẽ hiển thị sau khi quản trị viên tính lương.',
                                      icon: Icons.account_balance_wallet_outlined,
                                      action: AppButton(
                                        label: 'Thử lại',
                                        isOutlined: true,
                                        onPressed: _load,
                                      ),
                                    )
                                  else
                                    _PayrollContent(payroll: provider.payroll!),
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

class _MonthYearSelector extends StatelessWidget {
  const _MonthYearSelector({
    required this.month,
    required this.year,
    required this.onTap,
  });

  final int month;
  final int year;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.horizontalPadding(context) * 0.6,
        vertical: ResponsiveHelper.verticalSpacing(context, 14),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_month,
            color: AppColors.primary,
            size: ResponsiveHelper.responsiveIconSize(context, 22),
          ),
          SizedBox(width: ResponsiveHelper.verticalSpacing(context, 10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kỳ lương',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.responsiveFont(context, 12),
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  monthYearLabel(month, year),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.responsiveFont(context, 16),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.textSecondary,
            size: ResponsiveHelper.responsiveIconSize(context, 24),
          ),
        ],
      ),
    );
  }
}

class _PayrollContent extends StatelessWidget {
  const _PayrollContent({required this.payroll});

  final PayrollModel payroll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PayableCard(payroll: payroll),
        SizedBox(height: ResponsiveHelper.verticalSpacing(context, 14)),
        const AppSectionTitle('Tổng quan công'),
        StatGrid(
          children: [
            StatCard(
              label: 'Tổng giờ',
              value: formatHoursDecimal(payroll.totalHours),
              icon: Icons.schedule,
            ),
            StatCard(
              label: 'Ngày làm',
              value: '${payroll.workingDays}',
              icon: Icons.event_available,
              accentColor: AppColors.success,
            ),
            StatCard(
              label: 'Đi trễ',
              value: '${payroll.lateCount}',
              icon: Icons.warning_amber,
              accentColor: AppColors.warning,
            ),
            StatCard(
              label: 'Thiếu chấm ra',
              value: '${payroll.missingCheckoutDays}',
              icon: Icons.logout,
              accentColor: AppColors.textSecondary,
            ),
          ],
        ),
        SizedBox(height: ResponsiveHelper.verticalSpacing(context, 14)),
        _SalaryDetailCard(payroll: payroll),
        SizedBox(height: ResponsiveHelper.verticalSpacing(context, 14)),
        _EmployeeInfoCard(payroll: payroll),
        if (payroll.note != null && payroll.note!.trim().isNotEmpty) ...[
          SizedBox(height: ResponsiveHelper.verticalSpacing(context, 14)),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ghi chú',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.responsiveFont(context, 14),
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.verticalSpacing(context, 8)),
                Text(
                  payroll.note!.trim(),
                  style: TextStyle(
                    fontSize: ResponsiveHelper.responsiveFont(context, 14),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _PayableCard extends StatelessWidget {
  const _PayableCard({required this.payroll});

  final PayrollModel payroll;

  @override
  Widget build(BuildContext context) {
    final payLine = payroll.expectedPayDateLabel;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Thực trả',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.responsiveFont(context, 14),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              PayrollStatusBadge(status: payroll.status),
            ],
          ),
          SizedBox(height: ResponsiveHelper.verticalSpacing(context, 10)),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatCurrency(payroll.payableAmount),
              style: TextStyle(
                fontSize: ResponsiveHelper.responsiveFont(context, 34),
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          if (payLine != null) ...[
            SizedBox(height: ResponsiveHelper.verticalSpacing(context, 6)),
            Text(
              payLine,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: ResponsiveHelper.responsiveFont(context, 13),
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SalaryDetailCard extends StatelessWidget {
  const _SalaryDetailCard({required this.payroll});

  final PayrollModel payroll;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chi tiết lương',
            style: TextStyle(
              fontSize: ResponsiveHelper.responsiveFont(context, 16),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: ResponsiveHelper.verticalSpacing(context, 12)),
          _DetailRow(label: 'Lương cơ bản', value: formatCurrency(payroll.baseSalary)),
          _DetailRow(
            label: 'Giữ lại tháng này',
            value: formatCurrency(payroll.heldCurrentAmount),
          ),
          _DetailRow(
            label: 'Giữ từ tháng trước',
            value: formatCurrency(payroll.carryInHeldAmount),
          ),
          _DetailRow(
            label: 'Thưởng',
            value: formatCurrency(payroll.totalBonus),
            valueColor: AppColors.success,
          ),
          _DetailRow(
            label: 'Phạt',
            value: formatCurrency(payroll.totalPenalty),
            valueColor: AppColors.danger,
          ),
          _DetailRow(
            label: 'Khấu trừ cố định',
            value: formatCurrency(payroll.totalFixedDeduction),
          ),
          _DetailRow(
            label: 'Khấu trừ khác',
            value: formatCurrency(payroll.totalOtherDeduction),
          ),
          const Divider(height: 24),
          _DetailRow(
            label: 'Tổng khấu trừ',
            value: formatCurrency(payroll.totalDeductions),
            valueColor: AppColors.danger,
          ),
          _DetailRow(
            label: 'Thực trả',
            value: formatCurrency(payroll.payableAmount),
            isBold: true,
            valueColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _EmployeeInfoCard extends StatelessWidget {
  const _EmployeeInfoCard({required this.payroll});

  final PayrollModel payroll;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin nhân viên',
            style: TextStyle(
              fontSize: ResponsiveHelper.responsiveFont(context, 16),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: ResponsiveHelper.verticalSpacing(context, 12)),
          _DetailRow(label: 'Mã nhân viên', value: payroll.employeeCode),
          _DetailRow(label: 'Chi nhánh', value: payroll.branchName),
          _DetailRow(label: 'Chức vụ', value: payroll.position),
          _DetailRow(
            label: 'Lương/giờ',
            value: payroll.hourlyRateSnapshot > 0
                ? '${formatCurrency(payroll.hourlyRateSnapshot, useVndSuffix: true)}/giờ'
                : '--',
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveHelper.verticalSpacing(context, 10)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: ResponsiveHelper.responsiveFont(context, 14),
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: ResponsiveHelper.responsiveFont(context, 14),
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
