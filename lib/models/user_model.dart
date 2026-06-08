class UserModel {
  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    this.avatarUrl,
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String role;
  final String status;
  final String? avatarUrl;

  bool get isEmployee => role.toLowerCase() == 'employee';
  bool get isActive => status.toLowerCase() == 'active';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isBlocked {
    const blocked = ['locked', 'inactive', 'resigned', 'rejected'];
    return blocked.contains(status.toLowerCase());
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? role,
    String? status,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      status: status ?? this.status,
      avatarUrl: avatarUrl != null && avatarUrl.isEmpty ? '' : (avatarUrl ?? this.avatarUrl), // allow clearing avatar
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>? ?? json;

    return UserModel(
      id: userJson['_id']?.toString() ?? userJson['id']?.toString() ?? '',
      fullName: userJson['fullName']?.toString() ?? '',
      email: userJson['email']?.toString() ?? '',
      phone: userJson['phone']?.toString() ?? '',
      role: userJson['role']?.toString() ?? '',
      status: userJson['status']?.toString() ?? '',
      avatarUrl: userJson['avatarUrl']?.toString() ?? userJson['avatar']?.toString(),
    );
  }
}

class AuthResponse {
  const AuthResponse({required this.token, required this.user});

  final String token;
  final UserModel user;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final userJson = data['user'] as Map<String, dynamic>?;
    return AuthResponse(
      token: data['token']?.toString() ?? json['token']?.toString() ?? '',
      user: UserModel.fromJson(userJson ?? data),
    );
  }
}
