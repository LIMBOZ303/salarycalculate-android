import '../core/constants/api_endpoints.dart';
import '../core/network/dio_client.dart';
import '../core/utils/api_debug_log.dart';
import '../models/employee_model.dart';

class EmployeeService {
  EmployeeService(this._client);

  final DioClient _client;

  Future<EmployeeModel> getMe() async {
    const endpoint = ApiEndpoints.employeeMe;
    final response = await _client.get(endpoint);
    ApiDebugLog.logResponse(endpoint, data: response);

    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw Exception('Không lấy được thông tin nhân viên');
    }

    final employeeJson = data['employee'];
    if (employeeJson is Map<String, dynamic>) {
      return EmployeeModel.fromJson(employeeJson);
    }

    return EmployeeModel.fromJson(data);
  }
}
