import '../repositories/scanner_repository.dart';

class ClearScannerCacheUseCase {
  final ScannerRepository _repository;

  ClearScannerCacheUseCase(this._repository);

  Future<void> call() {
    return _repository.clearScannerCache();
  }
}
