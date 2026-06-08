import 'package:flutter/foundation.dart';

import '../core/constants/api_endpoints.dart';
import '../core/network/api_exception.dart';
import '../core/network/dio_client.dart';
import '../models/user_model.dart';

class AuthService {
  AuthService(this._client);

  final DioClient _client;

  Future<AuthResponse> register({
    required String fullName,
    required String phone,
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      ApiEndpoints.register,
      data: {
        'fullName': fullName,
        'phone': phone,
        'email': email,
        'password': password,
      },
    );
    return AuthResponse.fromJson(response);
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    return AuthResponse.fromJson(response);
  }

  Future<UserModel> getMe() async {
    final response = await _client.get(ApiEndpoints.me);

    if (kDebugMode) {
      debugPrint('[AuthService] /auth/me raw response: $response');
    }

    final payload = extractUserPayload(response);
    if (payload == null || !_hasIdentityFields(payload)) {
      throw ApiException(
        message: 'Không lấy được thông tin tài khoản',
        responseData: response,
      );
    }

    final user = UserModel.fromJson(payload);
    if (kDebugMode) {
      debugPrint(
        '[AuthService] parsed user role: ${user.role}, status: ${user.status}',
      );
    }
    return user;
  }

  bool _hasIdentityFields(Map<String, dynamic> payload) {
    return payload.containsKey('role') ||
        payload.containsKey('status') ||
        payload.containsKey('_id') ||
        payload.containsKey('id') ||
        payload.containsKey('email');
  }
}
