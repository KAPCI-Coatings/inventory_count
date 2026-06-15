import '../entity/barcode_entity.dart';

abstract class BarcodeRepository {
  Future<void> addBarcode(BarcodeEntity barcode);

  Future<BarcodeEntity?> getBarcodeById(String id);

  Future<BarcodeEntity?> getBarcodeByBarcodeNo(String barcode);

  Future<List<BarcodeEntity>> getAllBarcodes();

  Future<List<BarcodeEntity>> getBarcodes({
    String? id,
    String? batchNo,
    String? materialNo,
  });

  Future<void> deleteBarcodeById(String id);

  Future<void> deleteBarcodeByBarcodeNo(String barcode);

  Future<void> deleteBarcodesByBatch(String batchNo);

  Future<void> deleteBarcodesByMaterial(String materialNo);

  Future<void> syncBarcodes();

  Future<void> exportBarcodes();
}
