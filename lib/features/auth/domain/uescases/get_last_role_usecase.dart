
import 'package:inventory_count_flutter_app/features/auth/domain/repositories/auth_repository.dart';

class GetLastRoleUseCase {
  final AuthRepository _repository;

  GetLastRoleUseCase(this._repository);

  Future<String?> call() => _repository.getLastRole();
}
