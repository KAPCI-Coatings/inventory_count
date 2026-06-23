import 'package:inventory_count_flutter_app/domain/entities/scanner_settings.dart';

import '../repositories/scanner_repository.dart';

class SaveScannerSettingsUseCase {
	final ScannerRepository _repository;

	SaveScannerSettingsUseCase(this._repository);

	Future<void> call(ScannerSettings settings) {
		return _repository.saveSettings(settings);
	}
}
