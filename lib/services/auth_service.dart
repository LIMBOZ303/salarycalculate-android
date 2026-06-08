import 'package:flutter/foundation.dart';

import '../core/constants/api_endpoints.dart';
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
      print('--- DEBUG restoreAuth: raw response ---');
      print(response);
    }
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      final user = UserModel.fromJson(data);
      if (kDebugMode) {
        print('--- DEBUG restoreAuth: parsed role: ${user.role} ---');
        print('--- DEBUG restoreAuth: parsed status: ${user.status} ---');
      }
      return user;
    }
    throw Exception('Không lấy được thông tin tài khoản');
  }
}
