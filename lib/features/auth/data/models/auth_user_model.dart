import 'package:inventory_count_flutter_app/features/auth/domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  final String passwordHash;

  const AuthUserModel({required super.role, required this.passwordHash});

  factory AuthUserModel.fromMap(Map<String, Object?> map) {
    return AuthUserModel(
      role: (map['role'] ?? '').toString(),
      passwordHash: (map['password_hash'] ?? '').toString(),
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{'role': role, 'password_hash': passwordHash};
  }
}
