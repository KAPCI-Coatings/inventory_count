import 'package:inventory_count_flutter_app/domain/entities/barcode.dart';
import 'package:sqflite/sqflite.dart';
import 'package:inventory_count_flutter_app/core/error/empty_pallet_exception.dart';

abstract class BarcodeLocalDataSource {
  Future<int> getCurrentExportPalletNo();
  Future<int> startNewExportPallet();
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

  Future<int> _currentNumber(DatabaseExecutor db) async {
    final rows = await db.rawQuery('''
      SELECT MAX(currentExportPalletNo,
        COALESCE((SELECT MAX(exportPalletNo) FROM barcodes), 0)) AS number
      FROM inventory_session WHERE id = 1
    ''');
    return rows.single['number'] as int;
  }

  @override
  Future<int> getCurrentExportPalletNo() => _currentNumber(database);

  @override
  Future<int> startNewExportPallet() => database.transaction((txn) async {
    final current = await _currentNumber(txn);
    if (current > 0) {
      final rows = await txn.query(
        tableName,
        columns: ['id'],
        where: 'exportPalletNo = ?',
        whereArgs: [current],
        limit: 1,
      );
      if (rows.isEmpty) throw const EmptyPalletException();
    }
    final next = current + 1;
    await txn.update('inventory_session', {
      'currentExportPalletNo': next,
    }, where: 'id = 1');
    return next;
  });

  @override
  Future<void> saveBarcode(ItemBox item) async {
    final bool isPallet =
        item.isPallet || item.barCodeNo.toUpperCase().startsWith('P');
    final String palletBox = isPallet
        ? 'P'
        : (item.palletBox.isNotEmpty ? item.palletBox : 'B');
    final String serialNo = isPallet && item.barCodeNo.length == 21
        ? item.barCodeNo.substring(17, 21)
        : item.serialNo;

    await database.transaction((txn) async {
      await txn.insert(tableName, {
        'barCodeNo': item.barCodeNo,
        'matnr': item.matnr,
        'batchNo': item.batchNo,
        'serialNo': serialNo,
        'palletBox': palletBox,
        'qty': item.qty,
        'isPallet': isPallet ? 1 : 0,
        'isSent': item.isSent ? 1 : 0,
        'exportPalletNo': item.exportPalletNo,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      if (item.exportPalletNo != null) {
        await txn.rawUpdate(
          'UPDATE inventory_session SET currentExportPalletNo = MAX(currentExportPalletNo, ?) WHERE id = 1',
          [item.exportPalletNo],
        );
      }
    });
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
      orderBy: 'id ASC',
    );

    return List.generate(maps.length, (i) {
      final barcode = maps[i]['barCodeNo'] as String;
      final isPallet =
          (maps[i]['isPallet'] as int) == 1 ||
          barcode.toUpperCase().startsWith('P');
      String serialNo = maps[i]['serialNo'] as String;
      String palletBox = maps[i]['palletBox'] as String;

      if (isPallet) {
        palletBox = 'P';
        if (barcode.length == 21) {
          serialNo = barcode.substring(17, 21);
        }
      }

      return ItemBox(
        barCodeNo: barcode,
        matnr: maps[i]['matnr'] as String,
        batchNo: maps[i]['batchNo'] as String,
        serialNo: serialNo,
        palletBox: palletBox,
        qty: maps[i]['qty'] as int,
        isPallet: isPallet,
        isSent: (maps[i]['isSent'] as int?) == 1,
        exportPalletNo: maps[i]['exportPalletNo'] as int?,
      );
    });
  }

  @override
  Future<void> clearBarcodes() async {
    await database.transaction((txn) async {
      await txn.delete(tableName);
      await txn.update('inventory_session', {
        'currentExportPalletNo': 0,
      }, where: 'id = 1');
    });
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
