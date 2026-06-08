Map<String, dynamic>? extractUserPayload(dynamic responseData) {
  if (responseData is! Map) return null;

  final root = responseData;
  final data = root['data'];
  if (data is Map && data['user'] is Map) {
    return Map<String, dynamic>.from(data['user'] as Map);
  }
  if (root['user'] is Map) {
    return Map<String, dynamic>.from(root['user'] as Map);
  }
  if (data is Map) {
    return Map<String, dynamic>.from(data);
  }
  return Map<String, dynamic>.from(root);
}

class UserModel {
  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    this.avatar,
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String role;
  final String status;
  final String? avatar;

  bool get isEmployee => role.toLowerCase() == 'employee';
  bool get isActive => status.toLowerCase() == 'active';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isBlocked {
    const blocked = ['locked', 'inactive', 'resigned', 'rejected'];
    return blocked.contains(status.toLowerCase());
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
    );
  }
}

class AuthResponse {
  const AuthResponse({required this.token, required this.user});

  final String token;
  final UserModel user;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final userPayload = extractUserPayload(json);
    return AuthResponse(
      token: data['token']?.toString() ?? json['token']?.toString() ?? '',
      user: UserModel.fromJson(userPayload ?? data),
    );
  }
}
