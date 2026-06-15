import 'package:inventory_count_flutter_app/domain/repos/auth_repository.dart';


class InitializeAuthUseCase {
  final AuthRepository _repository;

  InitializeAuthUseCase(this._repository);

  Future<void> call() => _repository.initialize();
}
