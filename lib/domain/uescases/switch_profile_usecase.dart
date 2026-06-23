import '../repositories/scanner_repository.dart';

class SwitchProfileUseCase {
	final ScannerRepository _repository;

	SwitchProfileUseCase(this._repository);

	Future<void> call(String profileName) {
		return _repository.switchProfile(profileName);
	}
}
