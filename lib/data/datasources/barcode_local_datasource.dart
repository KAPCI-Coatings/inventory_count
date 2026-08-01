import 'package:inventory_count_flutter_app/domain/entities/barcode.dart';
import 'package:sqflite/sqflite.dart';

abstract class BarcodeLocalDataSource {
  Future<void> saveBarcode(ItemBox item);
  Future<bool> isDuplicate(String barcodeNo);
  Future<List<ItemBox>> getBarcodes({String? matnr, String? batchNo});
  Future<void> markAsSent(List<String> barcodes);
  Future<void> clearBarcodes();
}

class BarcodeLocalDataSourceImpl implements BarcodeLocalDataSource {
  final Database database;
  final String tableName = 'barcodes';

  BarcodeLocalDataSourceImpl(this.database);

  @override
  Future<void> saveBarcode(ItemBox item) async {
    await database.insert(
      tableName,
      {
        'barCodeNo': item.barCodeNo,
        'matnr': item.matnr,
        'batchNo': item.batchNo,
        'serialNo': item.serialNo,
        'palletBox': item.palletBox,
        'qty': item.qty,
        'isPallet': item.isPallet ? 1 : 0,
        'isSent': item.isSent ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<bool> isDuplicate(String barcodeNo) async {
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'barCodeNo = ?',
      whereArgs: [barcodeNo],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  @override
  Future<List<ItemBox>> getBarcodes({String? matnr, String? batchNo}) async {
    String? whereClause;
    List<dynamic> whereArgs = [];

    if (matnr != null && matnr.isNotEmpty) {
      whereClause = 'matnr LIKE ?';
      whereArgs.add('%$matnr%');
    }

    if (batchNo != null && batchNo.isNotEmpty) {
      if (whereClause != null) {
        whereClause += ' AND batchNo LIKE ?';
      } else {
        whereClause = 'batchNo LIKE ?';
      }
      whereArgs.add('%$batchNo%');
    }

    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: whereClause,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
    );

    return List.generate(maps.length, (i) {
      return ItemBox(
        barCodeNo: maps[i]['barCodeNo'] as String,
        matnr: maps[i]['matnr'] as String,
        batchNo: maps[i]['batchNo'] as String,
        serialNo: maps[i]['serialNo'] as String,
        palletBox: maps[i]['palletBox'] as String,
        qty: maps[i]['qty'] as int,
        isPallet: (maps[i]['isPallet'] as int) == 1,
        isSent: (maps[i]['isSent'] as int?) == 1,
      );
    });
  }

  @override
  Future<void> clearBarcodes() async {
    await database.delete(tableName);
  }

  @override
  Future<void> markAsSent(List<String> barcodes) async {
    if (barcodes.isEmpty) return;
    
    // SQLite has a limit on variables, but for normal batch size it's fine
    final placeholders = List.filled(barcodes.length, '?').join(',');
    await database.update(
      tableName,
      {'isSent': 1},
      where: 'barCodeNo IN ($placeholders)',
      whereArgs: barcodes,
    );
  }
}
