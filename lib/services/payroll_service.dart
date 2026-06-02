import '../core/constants/api_endpoints.dart';
import '../core/network/api_exception.dart';
import '../core/network/dio_client.dart';
import '../core/utils/api_debug_log.dart';
import '../models/payroll_model.dart';

class PayrollService {
  PayrollService(this._client);

  final DioClient _client;

  Future<PayrollModel?> getMyPayroll({
    required int month,
    required int year,
  }) async {
    const endpoint = ApiEndpoints.payrollMe;
    try {
      final response = await _client.get(
        endpoint,
        queryParameters: {'month': month, 'year': year},
      );
      ApiDebugLog.logResponse(endpoint, data: response);

      final payrollJson = PayrollModel.extractPayrollJson(response['data']);
      if (payrollJson == null) return null;

      final payroll = PayrollModel.fromJson(payrollJson);
      return payroll.hasData ? payroll : null;
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      if (e.statusCode == 403) {
        throw ApiException(
          message: e.message.isNotEmpty
              ? e.message
              : 'Bạn không có quyền xem bảng lương này.',
          statusCode: 403,
        );
      }
      rethrow;
    }
  }
}
