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
  sessionError,
  error,
}

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required AuthService authService,
    required SecureStorageService storage,
    required DioClient dioClient,
  })  : _authService = authService,
        _storage = storage,
        _dioClient = dioClient {
    DioClient.onUnauthorized = () {
      logout(silent: true, reason: '401 unauthorized');
    };
  }

  final AuthService _authService;
  final SecureStorageService _storage;
  final DioClient _dioClient;

  AuthStatus status = AuthStatus.initial;
  UserModel? user;
  String? errorMessage;

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null;

  Future<void> checkSession() async {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();

    final token = await _storage.getToken();
    final hasToken = token != null && token.isNotEmpty;
    if (kDebugMode) {
      debugPrint('[AuthProvider] splash restore token exists: $hasToken');
    }

    if (!hasToken) {
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    _dioClient.setAuthToken(token);
    await _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final me = await _authService.getMe();
      user = me;
      errorMessage = null;

      if (kDebugMode) {
        debugPrint('[AuthProvider] /auth/me success role=${me.role} status=${me.status}');
      }

      if (!me.isEmployee) {
        await _clearSession(reason: 'not employee');
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
        await _clearSession(reason: 'account blocked (${me.status})');
        status = AuthStatus.unauthenticated;
        errorMessage = 'Tài khoản không còn hoạt động';
      } else {
        await _clearSession(reason: 'invalid account status (${me.status})');
        status = AuthStatus.unauthenticated;
        errorMessage = 'Trạng thái tài khoản không hợp lệ';
      }
    } on ApiException catch (e) {
      await _handleAuthMeException(e);
    } catch (e) {
      status = AuthStatus.sessionError;
      errorMessage = 'Không thể xác thực phiên đăng nhập. Vui lòng thử lại.';
      if (kDebugMode) {
        debugPrint('[AuthProvider] session restore failed, token kept: $e');
      }
    }
    notifyListeners();
  }

  Future<void> _handleAuthMeException(ApiException e) async {
    final code = e.statusCode;

    if (code == 401 || _isTokenInvalidMessage(e.message)) {
      await _clearSession(reason: '${code ?? 401}: ${e.message}');
      status = AuthStatus.unauthenticated;
      errorMessage = e.message;
      return;
    }

    if (code == 403) {
      await _handleAuthMeForbidden(e);
      return;
    }

    status = AuthStatus.sessionError;
    errorMessage = e.message;
    if (kDebugMode) {
      debugPrint('[AuthProvider] /auth/me failed, token kept: ${e.message}');
    }
  }

  Future<void> _handleAuthMeForbidden(ApiException e) async {
    final parsedUser = _parseUserFromErrorResponse(e);

    if (parsedUser != null) {
      user = parsedUser;
      if (kDebugMode) {
        debugPrint(
          '[AuthProvider] /auth/me 403 user role=${parsedUser.role} status=${parsedUser.status}',
        );
      }

      if (!parsedUser.isEmployee) {
        await _clearSession(reason: 'invalid role (${parsedUser.role})');
        status = AuthStatus.error;
        errorMessage = 'Ứng dụng này chỉ dành cho nhân viên';
        return;
      }

      if (parsedUser.isPending) {
        status = AuthStatus.pending;
        errorMessage = null;
        return;
      }

      if (parsedUser.isBlocked) {
        await _clearSession(reason: 'account blocked (${parsedUser.status})');
        status = AuthStatus.unauthenticated;
        errorMessage = 'Tài khoản không còn hoạt động';
        return;
      }
    }

    final msg = e.message.toLowerCase();
    if (_isPendingMessage(msg)) {
      status = AuthStatus.pending;
      errorMessage = null;
      if (kDebugMode) {
        debugPrint('[AuthProvider] /auth/me 403 treated as pending from message');
      }
      return;
    }

    if (_isDeniedMessage(msg)) {
      await _clearSession(reason: '403 denied: ${e.message}');
      status = AuthStatus.unauthenticated;
      errorMessage = _mapDeniedMessage(e.message);
      return;
    }

    if (_isInvalidRoleMessage(msg)) {
      await _clearSession(reason: 'invalid role: ${e.message}');
      status = AuthStatus.error;
      errorMessage = 'Ứng dụng này chỉ dành cho nhân viên';
      return;
    }

    status = AuthStatus.sessionError;
    errorMessage = e.message;
    if (kDebugMode) {
      debugPrint('[AuthProvider] /auth/me 403 unknown, token kept: ${e.message}');
    }
  }

  UserModel? _parseUserFromErrorResponse(ApiException e) {
    final data = e.responseData;
    if (data == null) return null;

    final nestedData = data['data'];
    if (nestedData is Map<String, dynamic>) {
      final userJson = nestedData['user'];
      if (userJson is Map<String, dynamic>) {
        return UserModel.fromJson(userJson);
      }
      if (nestedData.containsKey('role') || nestedData.containsKey('status')) {
        return UserModel.fromJson(nestedData);
      }
    }

    final userJson = data['user'];
    if (userJson is Map<String, dynamic>) {
      return UserModel.fromJson(userJson);
    }

    return null;
  }

  bool _isTokenInvalidMessage(String message) {
    final msg = message.toLowerCase();
    return msg.contains('token') &&
        (msg.contains('invalid') ||
            msg.contains('expired') ||
            msg.contains('hết hạn') ||
            msg.contains('không hợp lệ'));
  }

  bool _isPendingMessage(String msg) {
    return msg.contains('pending') || msg.contains('chờ duyệt');
  }

  bool _isDeniedMessage(String msg) {
    return msg.contains('locked') ||
        msg.contains('blocked') ||
        msg.contains('denied') ||
        msg.contains('inactive') ||
        msg.contains('resigned') ||
        msg.contains('rejected') ||
        msg.contains('khóa') ||
        msg.contains('bị khóa') ||
        msg.contains('từ chối');
  }

  bool _isInvalidRoleMessage(String msg) {
    return msg.contains('employee only') ||
        msg.contains('chỉ dành cho nhân viên') ||
        (msg.contains('role') &&
            (msg.contains('invalid') ||
                msg.contains('forbidden') ||
                msg.contains('không hợp lệ')));
  }

  String _mapDeniedMessage(String message) {
    final msg = message.toLowerCase();
    if (msg.contains('locked') ||
        msg.contains('blocked') ||
        msg.contains('inactive') ||
        msg.contains('resigned') ||
        msg.contains('rejected') ||
        msg.contains('khóa') ||
        msg.contains('denied') ||
        msg.contains('từ chối')) {
      return 'Tài khoản không còn hoạt động';
    }
    return message;
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
      _dioClient.setAuthToken(result.token);
      user = result.user;

      if (kDebugMode) {
        debugPrint('[AuthProvider] login token saved (exists: ${result.token.isNotEmpty})');
        debugPrint('[AuthProvider] login user role=${result.user.role} status=${result.user.status}');
      }

      if (result.user.isPending) {
        status = AuthStatus.pending;
      } else if (result.user.isActive) {
        status = AuthStatus.authenticated;
      } else if (result.user.isBlocked) {
        await _clearSession(reason: 'account blocked on login');
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
        _dioClient.setAuthToken(result.token);
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

  Future<void> logout({bool silent = false, String? reason}) async {
    await _clearSession(reason: reason ?? 'user logout');
    if (!silent) {
      errorMessage = null;
    }
    notifyListeners();
  }

  Future<void> _clearSession({required String reason}) async {
    if (kDebugMode) {
      debugPrint('[AuthProvider] logout reason: $reason');
    }
    await _storage.deleteToken();
    _dioClient.clearAuthToken();
    user = null;
    status = AuthStatus.unauthenticated;
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
