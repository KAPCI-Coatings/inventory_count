import 'package:inventory_count_flutter_app/domain/repositories/auth_repository.dart';

class IsLoggedInUseCase {
  final AuthRepository _repository;

  IsLoggedInUseCase(this._repository);

  Future<bool> call() async {
    return _repository.isLoggedIn();
  }
}
