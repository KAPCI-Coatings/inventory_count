import 'package:inventory_count_flutter_app/domain/entities/scanner_cache.dart';

import '../repositories/scanner_repository.dart';

class LoadScannerCacheUseCase {
  final ScannerRepository _repository;

  LoadScannerCacheUseCase(this._repository);

  Future<ScannerCache> call() {
    return _repository.loadScannerCache();
  }
}
