import 'package:inventory_count_flutter_app/features/auth/domain/repositories/auth_repository.dart';

class InitializeAuthUseCase {
  final AuthRepository _repository;

  InitializeAuthUseCase(this._repository);

  Future<void> call() => _repository.initialize();
}
