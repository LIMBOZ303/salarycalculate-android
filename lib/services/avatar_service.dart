import 'dart:io';
import 'package:dio/dio.dart';

import '../core/network/dio_client.dart';

class AvatarService {
  AvatarService(this._client);
  final DioClient _client;
  /// Upload avatar
  Future<String?> uploadMyAvatar(File file) async {
    if (!await file.exists()) {
      throw Exception('File không tồn tại');
    }

    final size = await file.length();
    if (size > 5 * 1024 * 1024) {
      throw Exception('Kích thước ảnh không được vượt quá 5MB');
    }

    final ext = file.path.split('.').last.toLowerCase();
    if (!['jpg', 'jpeg', 'png', 'webp'].contains(ext)) {
      throw Exception('Chỉ hỗ trợ định dạng JPG, PNG, WEBP');
    }

    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(file.path),
    });

    final response = await _client.patch(
      '/api/users/me/avatar',
      data: formData,
    );

    final data = response['data'];
    if (data is Map) {
      final avatarUrl = data['avatarUrl']?.toString() ??
          (data['user'] is Map ? data['user']['avatarUrl']?.toString() : null) ??
          (data['user'] is Map ? data['user']['avatar']?.toString() : null);
      return avatarUrl;
    }
    return response['avatarUrl']?.toString();
  }

  /// Delete avatar
  Future<void> deleteMyAvatar() async {
    await _client.delete('/api/users/me/avatar');
  }
}
