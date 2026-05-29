import '../core/constants/api_endpoints.dart';
import '../core/network/api_exception.dart';
import '../core/network/dio_client.dart';
import '../core/utils/api_debug_log.dart';
import '../models/attendance_model.dart';
import '../models/attendance_summary_model.dart';
import 'device_service.dart';
import 'location_service.dart';

class AttendanceService {
  AttendanceService(
    this._client,
    this._locationService,
    this._deviceService,
  );

  final DioClient _client;
  final LocationService _locationService;
  final DeviceService _deviceService;

  Future<TodayAttendanceModel> getToday() async {
    const endpoint = ApiEndpoints.attendanceToday;
    final response = await _client.get(endpoint);
    ApiDebugLog.logResponse(endpoint, data: response);

    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return TodayAttendanceModel.fromApiPayload(data);
    }
    return const TodayAttendanceModel();
  }

  Future<AttendanceSummaryModel> getSummary({
    required int month,
    required int year,
  }) async {
    const endpoint = ApiEndpoints.attendanceSummary;
    final response = await _client.get(
      endpoint,
      queryParameters: {'month': month, 'year': year},
    );
    ApiDebugLog.logResponse(endpoint, data: response);

    final data = response['data'];
    if (data is Map<String, dynamic>) {
      final summaryJson = data['summary'];
      if (summaryJson is Map<String, dynamic>) {
        return AttendanceSummaryModel.fromJson(summaryJson);
      }
      return AttendanceSummaryModel.fromJson(data);
    }
    return AttendanceSummaryModel(month: month, year: year);
  }

  Future<List<AttendanceHistoryItem>> getHistory({
    required int month,
    required int year,
  }) async {
    const endpoint = ApiEndpoints.attendanceHistory;
    final response = await _client.get(
      endpoint,
      queryParameters: {'month': month, 'year': year},
    );
    ApiDebugLog.logResponse(endpoint, data: response);

    final data = response['data'];
    if (data is Map<String, dynamic>) {
      final history = data['history'];
      if (history is List) {
        return history
            .whereType<Map<String, dynamic>>()
            .map(AttendanceHistoryItem.fromJson)
            .toList();
      }
      final items = data['items'] ?? data['attendances'];
      if (items is List) {
        return items
            .whereType<Map<String, dynamic>>()
            .map(AttendanceHistoryItem.fromJson)
            .toList();
      }
    }
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(AttendanceHistoryItem.fromJson)
          .toList();
    }
    return [];
  }

  Future<TodayAttendanceModel> checkIn() async {
    return _check('in');
  }

  Future<TodayAttendanceModel> checkOut() async {
    return _check('out');
  }

  Future<TodayAttendanceModel> _check(String type) async {
    final location = await _locationService.getCurrentLocation();
    final device = await _deviceService.getDeviceInfo();
    final path = type == 'in' ? ApiEndpoints.checkIn : ApiEndpoints.checkOut;

    try {
      final response = await _client.post(
        path,
        data: {
          'latitude': location.latitude,
          'longitude': location.longitude,
          'accuracy': location.accuracy,
          'deviceInfo': device.toJson(),
        },
      );
      ApiDebugLog.logResponse(path, data: response);

      final data = response['data'];
      if (data is Map<String, dynamic>) {
        return TodayAttendanceModel.fromApiPayload(data);
      }
      return getToday();
    } on ApiException catch (e) {
      throw _mapAttendanceError(e);
    }
  }

  ApiException _mapAttendanceError(ApiException e) {
    final msg = e.message.toLowerCase();
    final status = e.statusCode;

    if (status == 403 || msg.contains('radius') || msg.contains('khu vực')) {
      return ApiException(
        message: 'Bạn đang ở ngoài khu vực chấm công.',
        statusCode: status,
      );
    }
    if (status == 400 && (msg.contains('accuracy') || msg.contains('chính xác'))) {
      return ApiException(
        message: 'Vị trí chưa đủ chính xác, vui lòng thử lại.',
        statusCode: status,
      );
    }
    return e;
  }
}
