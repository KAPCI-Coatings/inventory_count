
import 'package:inventory_count_flutter_app/domain/entities/auth_user.dart';

abstract class AuthRepository {
  Future<void> initialize();

  Future<AuthUser?> login({required String role, required String password});

  Future<bool> changePassword({
    required String actorRole,
    required String targetRole,
    required String newPassword,
  });

  Future<String?> getLastRole();

  Future<bool> isLoggedIn();

  Future<void> logout();
}
