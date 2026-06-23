import '../repositories/scanner_repository.dart';

class EnableScannerUseCase {
	final ScannerRepository _repository;

	EnableScannerUseCase(this._repository);

	Future<void> call() {
		return _repository.enableScanner();
	}
}