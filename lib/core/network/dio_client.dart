import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../storage/secure_storage_service.dart';
import 'api_exception.dart';

typedef UnauthorizedCallback = void Function();

class DioClient {
  DioClient(this._storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            onUnauthorized?.call();
          }
          handler.next(error);
        },
      ),
    );
  }

  final SecureStorageService _storage;
  late final Dio _dio;

  static UnauthorizedCallback? onUnauthorized;

  Dio get dio => _dio;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<dynamic>(path, queryParameters: queryParameters);
      return _parseResponse(response.data);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.post<dynamic>(path, data: data);
      return _parseResponse(response.data);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Map<String, dynamic> _parseResponse(dynamic data) {
    if (data is! Map<String, dynamic>) {
      throw ApiException(message: 'Phản hồi không hợp lệ từ máy chủ');
    }

    final success = data['success'] == true;
    if (!success) {
      throw ApiException(
        message: data['message']?.toString() ?? 'Có lỗi xảy ra',
        error: data['error']?.toString(),
      );
    }

    return data;
  }

  ApiException _mapDioError(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString() ??
          data['error']?.toString() ??
          'Có lỗi xảy ra';
      if (status == 401) {
        onUnauthorized?.call();
      }
      return ApiException(
        message: message,
        statusCode: status,
        error: data['error']?.toString(),
      );
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return ApiException(message: 'Kết nối quá thời gian, vui lòng thử lại');
    }

    if (e.type == DioExceptionType.connectionError) {
      return ApiException(
        message: 'Không kết nối được máy chủ. Kiểm tra mạng và địa chỉ API.',
      );
    }

    return ApiException(
      message: 'Lỗi mạng (${e.message ?? 'unknown'})',
      statusCode: status,
    );
  }
}
