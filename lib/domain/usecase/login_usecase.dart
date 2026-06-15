import 'package:inventory_count_flutter_app/domain/entity/auth_user.dart';
import 'package:inventory_count_flutter_app/domain/repos/auth_repository.dart';


class LoginParams {
  final String role;
  final String password;

  const LoginParams({required this.role, required this.password});
}

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<AuthUser?> call(LoginParams params) {
    return _repository.login(role: params.role, password: params.password);
  }
}
