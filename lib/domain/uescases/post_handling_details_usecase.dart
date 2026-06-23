import '../entities/item_box.dart';
import '../repositories/scanner_repository.dart';

class PostHandlingDetailsUseCase {
  final ScannerRepository _repository;

  PostHandlingDetailsUseCase(this._repository);

  Future<void> call({
    required String baseUrl,
    required int devId,
    required List<ItemBox> itemBoxes,
  }) {
    return _repository.postHandlingDetails(
      baseUrl: baseUrl,
      devId: devId,
      itemBoxes: itemBoxes,
    );
  }
}
