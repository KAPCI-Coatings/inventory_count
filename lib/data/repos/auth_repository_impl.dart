import 'package:inventory_count_flutter_app/data/datasource/auth_local_datasource.dart';
import 'package:inventory_count_flutter_app/data/model/auth_user_model.dart';
import 'package:inventory_count_flutter_app/domain/entity/auth_user.dart';
import 'package:inventory_count_flutter_app/domain/repos/auth_repository.dart';


class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl({required AuthLocalDataSource localDataSource})
    : _localDataSource = localDataSource;

  @override
  Future<void> initialize() => _localDataSource.initializeUsers();

  @override
  Future<AuthUser?> login({
    required String role,
    required String password,
  }) async {
    final String normalizedRole = role.trim();
    if (normalizedRole != 'Admin' && normalizedRole != 'User') {
      return null;
    }

    if (password.trim().isEmpty) {
      return null;
    }

    final AuthUserModel? userModel = await _localDataSource.getUserByRole(
      normalizedRole,
    );
    if (userModel == null) {
      return null;
    }

    if (userModel.passwordHash != hashAuthPin(password)) {
      return null;
    }

    await _localDataSource.saveSession(role: normalizedRole);

    return AuthUser(role: normalizedRole);
  }

  @override
  Future<bool> changePassword({
    required String actorRole,
    required String targetRole,
    required String newPassword,
  }) async {
    if (actorRole != 'Admin') {
      return false;
    }

    if (targetRole != 'Admin' && targetRole != 'User') {
      return false;
    }

    if (newPassword.trim().isEmpty) {
      return false;
    }

    return _localDataSource.updatePassword(
      role: targetRole,
      password: newPassword,
    );
  }

  @override
  Future<String?> getLastRole() => _localDataSource.getLastRole();
}
