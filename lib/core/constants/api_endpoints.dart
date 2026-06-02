class ApiEndpoints {
  ApiEndpoints._();

  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String me = '/api/auth/me';
  static const String employeeMe = '/api/employees/me';
  static const String checkIn = '/api/attendance/check-in';
  static const String checkOut = '/api/attendance/check-out';
  static const String attendanceToday = '/api/attendance/me/today';
  static const String attendanceSummary = '/api/attendance/me/summary';
  static const String attendanceHistory = '/api/attendance/me/history';
  static const String payrollMe = '/api/payrolls/me';
}
