import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../core/network/dio_client.dart';
import '../core/storage/secure_storage_service.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus {
  initial,
  loading,
  unauthenticated,
  authenticated,
  pending,
  error,
}

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required AuthService authService,
    required SecureStorageService storage,
  })  : _authService = authService,
        _storage = storage {
    DioClient.onUnauthorized = () {
      logout(silent: true);
    };
  }

  final AuthService _authService;
  final SecureStorageService _storage;

  AuthStatus status = AuthStatus.initial;
  UserModel? user;
  String? errorMessage;

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null;

  Future<void> checkSession() async {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();

    final hasToken = await _storage.hasToken();
    if (!hasToken) {
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    await _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final me = await _authService.getMe();
      user = me;
      errorMessage = null;

      if (!me.isEmployee) {
        await _storage.deleteToken();
        status = AuthStatus.error;
        errorMessage = 'Ứng dụng này chỉ dành cho nhân viên';
        notifyListeners();
        return;
      }

      if (me.isPending) {
        status = AuthStatus.pending;
      } else if (me.isActive) {
        status = AuthStatus.authenticated;
      } else if (me.isBlocked) {
        await _storage.deleteToken();
        status = AuthStatus.unauthenticated;
        errorMessage = 'Tài khoản không còn hoạt động';
      } else {
        await _storage.deleteToken();
        status = AuthStatus.unauthenticated;
        errorMessage = 'Trạng thái tài khoản không hợp lệ';
      }
    } on ApiException catch (e) {
      await _storage.deleteToken();
      status = AuthStatus.unauthenticated;
      errorMessage = e.message;
    } catch (e) {
      await _storage.deleteToken();
      status = AuthStatus.unauthenticated;
      errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.login(email: email, password: password);
      if (!result.user.isEmployee) {
        status = AuthStatus.error;
        errorMessage = 'Ứng dụng này chỉ dành cho nhân viên';
        notifyListeners();
        return false;
      }

      await _storage.saveToken(result.token);
      user = result.user;

      if (result.user.isPending) {
        status = AuthStatus.pending;
      } else if (result.user.isActive) {
        status = AuthStatus.authenticated;
      } else if (result.user.isBlocked) {
        await _storage.deleteToken();
        status = AuthStatus.unauthenticated;
        errorMessage = 'Tài khoản không còn hoạt động';
        notifyListeners();
        return false;
      } else {
        status = AuthStatus.error;
        errorMessage = 'Không thể đăng nhập';
      }
      notifyListeners();
      return status == AuthStatus.authenticated || status == AuthStatus.pending;
    } on ApiException catch (e) {
      status = AuthStatus.unauthenticated;
      errorMessage = _mapLoginError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String phone,
    required String email,
    required String password,
  }) async {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.register(
        fullName: fullName,
        phone: phone,
        email: email,
        password: password,
      );
      if (result.token.isNotEmpty) {
        await _storage.saveToken(result.token);
      }
      user = result.user;
      status = AuthStatus.pending;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      status = AuthStatus.unauthenticated;
      errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshStatus() => _loadCurrentUser();

  Future<void> logout({bool silent = false}) async {
    await _storage.deleteToken();
    user = null;
    status = AuthStatus.unauthenticated;
    if (!silent) {
      errorMessage = null;
    }
    notifyListeners();
  }

  String _mapLoginError(ApiException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('pending') || msg.contains('chờ duyệt')) {
      return 'Tài khoản đang chờ admin duyệt';
    }
    if (msg.contains('locked') ||
        msg.contains('inactive') ||
        msg.contains('resigned') ||
        msg.contains('rejected') ||
        msg.contains('khóa')) {
      return 'Tài khoản không còn hoạt động';
    }
    return e.message;
  }
}
