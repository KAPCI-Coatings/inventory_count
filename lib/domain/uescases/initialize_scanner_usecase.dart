import '../repositories/scanner_repository.dart';

class InitializeScannerUseCase {
	final ScannerRepository _repository;

	InitializeScannerUseCase(this._repository);

	Future<void> call() {
		return _repository.initialize();
	}
}
