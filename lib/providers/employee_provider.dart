import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../models/employee_model.dart';
import '../services/employee_service.dart';

class EmployeeProvider extends ChangeNotifier {
  EmployeeProvider(this._service);

  final EmployeeService _service;

  EmployeeModel? employee;
  bool isLoading = false;
  String? error;

  Future<void> loadMyProfile({bool force = false}) async {
    if (employee != null && !force && !isLoading) return;

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      employee = await _service.getMe();
      error = null;
    } on ApiException catch (e) {
      employee = null;
      error = e.message;
    } catch (e) {
      employee = null;
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Alias giữ tương thích code cũ.
  Future<void> loadEmployee({bool force = false}) => loadMyProfile(force: force);

  void clear() {
    employee = null;
    error = null;
    isLoading = false;
    notifyListeners();
  }

  void updateAvatarUrl(String? url) {
    if (employee != null) {
      employee = employee!.copyWith(avatarUrl: url);
      notifyListeners();
    }
  }
}
