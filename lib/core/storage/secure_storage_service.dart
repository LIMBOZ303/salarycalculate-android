import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        );

  static const tokenKey = 'auth_token';

  final FlutterSecureStorage _storage;

  Future<void> saveToken(String token) async {
    await _storage.write(key: tokenKey, value: token);
    if (kDebugMode) {
      debugPrint('[SecureStorage] token saved (exists: ${token.isNotEmpty})');
    }
  }

  Future<String?> getToken() => _storage.read(key: tokenKey);

  Future<void> deleteToken() async {
    await _storage.delete(key: tokenKey);
    if (kDebugMode) {
      debugPrint('[SecureStorage] token deleted');
    }
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
