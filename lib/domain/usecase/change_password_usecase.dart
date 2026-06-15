import 'package:inventory_count_flutter_app/domain/repos/auth_repository.dart';


class ChangePasswordParams {
  final String actorRole;
  final String targetRole;
  final String newPassword;

  const ChangePasswordParams({
    required this.actorRole,
    required this.targetRole,
    required this.newPassword,
  });
}

class ChangePasswordUseCase {
  final AuthRepository _repository;

  ChangePasswordUseCase(this._repository);

  Future<bool> call(ChangePasswordParams params) {
    return _repository.changePassword(
      actorRole: params.actorRole,
      targetRole: params.targetRole,
      newPassword: params.newPassword,
    );
  }
}
