import 'package:inventory_count_flutter_app/core/error/barcode_exceptions.dart';
import 'package:inventory_count_flutter_app/domain/entities/barcode.dart';
import 'package:inventory_count_flutter_app/domain/repositories/barcode_repository.dart';

/// Result returned by [ProcessBarcodeUseCase].
///
/// [isDuplicate] is `true` when the barcode already exists in the current
/// session. The barcode is **still saved and counted** so the operator can
/// confirm a physical re-count, but the UI should show a visible warning.
class ProcessBarcodeResult {
  final ItemBox itemBox;

  /// `true` when this barcode was already scanned before in the session.
  final bool isDuplicate;

  const ProcessBarcodeResult({
    required this.itemBox,
    this.isDuplicate = false,
  });
}

class ProcessBarcodeUseCase {
  final BarcodeRepository repository;

  ProcessBarcodeUseCase(this.repository);

  Future<ProcessBarcodeResult> call(String rawBarcode) async {
    // 1. Validate Length — still required for the inventory barcode format
    if (rawBarcode.length != 20 && rawBarcode.length != 21) {
      throw const InvalidBarcodeFormatException('invalid_barcode_length');
    }

    // 2. Check for Duplicate — record but do NOT block
    final bool isDuplicate = await repository.isDuplicate(rawBarcode);

    // 3. Parse Barcode
    ItemBox itemBox;

    if (rawBarcode.length == 20) {
      // BOX FORMAT (20 digits): matnr (6) | batch (10) | serial (4)
      final matnr = rawBarcode.substring(0, 6);
      final batchNo = rawBarcode.substring(6, 16);
      final serialNo = rawBarcode.substring(16, 20);

      itemBox = ItemBox(
        barCodeNo: rawBarcode,
        matnr: matnr,
        batchNo: batchNo,
        serialNo: serialNo,
        qty: 1,
        isPallet: false,
      );
    } else {
      // PALLET FORMAT (21 digits): P (1) | matnr (6) | batch (10) | palletBox (1) | qty (3)
      if (!rawBarcode.startsWith('P') && !rawBarcode.startsWith('p')) {
        throw const InvalidBarcodeFormatException('invalid_pallet_prefix');
      }

      final matnr = rawBarcode.substring(1, 7);
      final batchNo = rawBarcode.substring(7, 17);
      final palletBox = rawBarcode.substring(17, 18);
      final qtyString = rawBarcode.substring(18, 21);
      final qty = int.tryParse(qtyString) ?? 0;

      itemBox = ItemBox(
        barCodeNo: rawBarcode,
        matnr: matnr,
        batchNo: batchNo,
        palletBox: palletBox,
        palletNo: int.tryParse(palletBox),
        qty: qty,
        isPallet: true,
      );
    }

    // 4. Save to Repository ONLY if NOT duplicate.
    // If it's a duplicate, we wait for user confirmation.
    if (!isDuplicate) {
      await repository.saveScannedBarcode(itemBox);
    }

    return ProcessBarcodeResult(itemBox: itemBox, isDuplicate: isDuplicate);
  }
}
