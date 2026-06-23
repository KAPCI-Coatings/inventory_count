import '../entities/scanner_settings.dart';
import '../../../../domain/repositories/scanner_repository.dart';

class GetScannerSettingsUseCase {
	final ScannerRepository _repository;

	GetScannerSettingsUseCase(this._repository);

	Future<ScannerSettings> call() {
		return _repository.getSettings();
	}
}
