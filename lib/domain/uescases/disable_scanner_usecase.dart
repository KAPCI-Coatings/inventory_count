import '../repositories/scanner_repository.dart';

class DisableScannerUseCase {
	final ScannerRepository _repository;

	DisableScannerUseCase(this._repository);

	Future<void> call() {
		return _repository.disableScanner();
	}
}