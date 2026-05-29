import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../models/attendance_model.dart';
import '../models/attendance_summary_model.dart';
import '../services/attendance_service.dart';

class AttendanceProvider extends ChangeNotifier {
  AttendanceProvider(this._service);

  final AttendanceService _service;

  TodayAttendanceModel? today;
  AttendanceSummaryModel? summary;
  List<AttendanceHistoryItem> history = [];

  bool isLoadingToday = false;
  bool isLoadingSummary = false;
  bool isLoadingHistory = false;
  bool isChecking = false;

  String? todayError;
  String? summaryError;
  String? historyError;
  String? checkError;

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  Future<void> loadTodayAttendance() async {
    isLoadingToday = true;
    todayError = null;
    notifyListeners();

    try {
      today = await _service.getToday();
      todayError = null;
    } on ApiException catch (e) {
      todayError = e.message;
    } catch (e) {
      todayError = e.toString();
    } finally {
      isLoadingToday = false;
      notifyListeners();
    }
  }

  Future<void> loadToday() => loadTodayAttendance();

  Future<void> loadSummary({int? month, int? year}) async {
    final m = month ?? selectedMonth;
    final y = year ?? selectedYear;
    selectedMonth = m;
    selectedYear = y;

    isLoadingSummary = true;
    summaryError = null;
    notifyListeners();

    try {
      summary = await _service.getSummary(month: m, year: y);
      summaryError = null;
    } on ApiException catch (e) {
      summaryError = e.message;
    } catch (e) {
      summaryError = e.toString();
    } finally {
      isLoadingSummary = false;
      notifyListeners();
    }
  }

  Future<void> loadHistory({int? month, int? year}) async {
    final m = month ?? selectedMonth;
    final y = year ?? selectedYear;
    selectedMonth = m;
    selectedYear = y;

    isLoadingHistory = true;
    historyError = null;
    notifyListeners();

    try {
      history = await _service.getHistory(month: m, year: y);
      historyError = null;
    } on ApiException catch (e) {
      history = [];
      historyError = e.message;
    } catch (e) {
      history = [];
      historyError = e.toString();
    } finally {
      isLoadingHistory = false;
      notifyListeners();
    }
  }

  Future<void> refreshAll() async {
    final now = DateTime.now();
    await Future.wait([
      loadTodayAttendance(),
      loadSummary(month: now.month, year: now.year),
      loadHistory(month: now.month, year: now.year),
    ]);
    notifyListeners();
  }

  Future<bool> checkIn() async {
    isChecking = true;
    checkError = null;
    notifyListeners();

    try {
      today = await _service.checkIn();
      await refreshAll();
      return true;
    } on ApiException catch (e) {
      checkError = e.message;
      return false;
    } catch (e) {
      checkError = e.toString();
      return false;
    } finally {
      isChecking = false;
      notifyListeners();
    }
  }

  Future<bool> checkOut() async {
    isChecking = true;
    checkError = null;
    notifyListeners();

    try {
      today = await _service.checkOut();
      await refreshAll();
      return true;
    } on ApiException catch (e) {
      checkError = e.message;
      return false;
    } catch (e) {
      checkError = e.toString();
      return false;
    } finally {
      isChecking = false;
      notifyListeners();
    }
  }

  Future<void> loadHomeData() async {
    final now = DateTime.now();
    await Future.wait([
      loadTodayAttendance(),
      loadSummary(month: now.month, year: now.year),
    ]);
    notifyListeners();
  }

  void clear() {
    today = null;
    summary = null;
    history = [];
    todayError = null;
    summaryError = null;
    historyError = null;
    checkError = null;
    notifyListeners();
  }
}
