import 'package:inventory_count_flutter_app/domain/entities/scanner_cache.dart';

import '../repositories/scanner_repository.dart';

class SaveScannerCacheUseCase {
  final ScannerRepository _repository;

  SaveScannerCacheUseCase(this._repository);

  Future<void> call(ScannerCache cache) {
    return _repository.saveScannerCache(cache);
  }
}
