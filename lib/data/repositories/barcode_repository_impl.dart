import 'package:inventory_count_flutter_app/data/datasources/barcode_local_datasource.dart';
import 'package:inventory_count_flutter_app/domain/entities/barcode.dart';
import 'package:inventory_count_flutter_app/domain/repositories/barcode_repository.dart';

class BarcodeRepositoryImpl implements BarcodeRepository {
  final BarcodeLocalDataSource _localDataSource;

  BarcodeRepositoryImpl(this._localDataSource);

  @override
  Future<void> saveScannedBarcode(ItemBox item) async {
    await _localDataSource.saveBarcode(item);
  }

  @override
  Future<bool> isDuplicate(String barcodeNo) async {
    return await _localDataSource.isDuplicate(barcodeNo);
  }

  @override
  Future<List<ItemBox>> getScannedItems({String? matnr, String? batchNo}) async {
    return await _localDataSource.getBarcodes(matnr: matnr, batchNo: batchNo);
  }

  @override
  Future<void> clearSession() async {
    await _localDataSource.clearBarcodes();
  }
}

