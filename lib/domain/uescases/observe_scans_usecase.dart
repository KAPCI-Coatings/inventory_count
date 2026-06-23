import 'package:inventory_count_flutter_app/domain/entities/scan_item.dart';

import '../repositories/scanner_repository.dart';

class ObserveScansUseCase {
	final ScannerRepository _repository;

	ObserveScansUseCase(this._repository);

	Stream<ScanItem> call() {
		return _repository.observeScans();
	}
}
