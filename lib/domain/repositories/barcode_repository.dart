import 'package:inventory_count_flutter_app/domain/entities/barcode.dart';

abstract class BarcodeRepository {
  /// Saves a scanned barcode to the current session.
  Future<void> saveScannedBarcode(ItemBox item);

  /// Marks a list of barcodes as sent.
  Future<void> markAsSent(List<String> barcodes);

  /// Checks if a barcode string has already been scanned in the current session.
  Future<bool> isDuplicate(String barcodeNo);

  /// Retrieves all scanned items in the current session.
  Future<List<ItemBox>> getScannedItems({String? matnr, String? batchNo});

  /// Clears the current session.
  Future<void> clearSession();
}
