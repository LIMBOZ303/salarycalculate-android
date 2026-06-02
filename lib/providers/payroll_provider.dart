import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../models/payroll_model.dart';
import '../services/payroll_service.dart';

class PayrollProvider extends ChangeNotifier {
  PayrollProvider(this._service);

  final PayrollService _service;

  PayrollModel? payroll;
  bool isLoading = false;
  String? error;

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  Future<void> loadMyPayroll(int month, int year) async {
    selectedMonth = month;
    selectedYear = year;
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      payroll = await _service.getMyPayroll(month: month, year: year);
      error = null;
    } on ApiException catch (e) {
      payroll = null;
      error = _mapError(e);
    } catch (e) {
      payroll = null;
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => loadMyPayroll(selectedMonth, selectedYear);

  void setMonthYear(int month, int year) {
    if (selectedMonth == month && selectedYear == year) return;
    selectedMonth = month;
    selectedYear = year;
    notifyListeners();
  }

  void clear() {
    payroll = null;
    isLoading = false;
    error = null;
    selectedMonth = DateTime.now().month;
    selectedYear = DateTime.now().year;
    notifyListeners();
  }

  String _mapError(ApiException e) {
    if (e.statusCode == 403) {
      return e.message.isNotEmpty
          ? e.message
          : 'Bạn không có quyền xem bảng lương.';
    }
    return e.message;
  }
}
