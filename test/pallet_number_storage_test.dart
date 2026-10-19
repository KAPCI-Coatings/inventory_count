import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_count_flutter_app/core/error/empty_pallet_exception.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:inventory_count_flutter_app/data/datasources/inventory_database_schema.dart';
import 'package:inventory_count_flutter_app/data/datasources/barcode_local_datasource.dart';
import 'package:inventory_count_flutter_app/domain/entities/barcode.dart';

void main() {
  sqfliteFfiInit();
  late Database db;
  late BarcodeLocalDataSourceImpl source;
  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await createInventorySchema(db);
    source = BarcodeLocalDataSourceImpl(db);
  });
  tearDown(() async => db.close());

  test(
    'numbers round-trip and duplicate pallets retain separate rows',
    () async {
      for (final number in [1, 4]) {
        await source.saveBarcode(
          ItemBox(
            barCodeNo: 'P1234560000000001Z025',
            matnr: '123456',
            batchNo: '0000000001',
            serialNo: 'Z025',
            palletBox: 'P',
            qty: 25,
            isPallet: true,
            exportPalletNo: number,
          ),
        );
      }
      final rows = await source.getBarcodes();
      expect(rows.map((r) => r.exportPalletNo), [1, 4]);
      expect(rows.last.batchNo, '0000000001');
      expect(rows.last.isSent, false);
      await source.markAsSent([rows.last.barCodeNo]);
      expect((await source.getBarcodes()).last.exportPalletNo, 4);
      expect((await source.getBarcodes()).last.isSent, true);
      expect(await source.getCurrentExportPalletNo(), 4);
    },
  );

  test(
    'empty reservations survive reconstruction and clear resets them',
    () async {
      expect(await source.startNewExportPallet(), 1);
      await expectLater(
        source.startNewExportPallet(),
        throwsA(isA<EmptyPalletException>()),
      );
      source = BarcodeLocalDataSourceImpl(db);
      expect(await source.getCurrentExportPalletNo(), 1);
      expect(await source.getBarcodes(), isEmpty);
      await expectLater(
        source.startNewExportPallet(),
        throwsA(isA<EmptyPalletException>()),
      );
      await source.saveBarcode(
        const ItemBox(barCodeNo: 'box', exportPalletNo: 1),
      );
      expect(await source.startNewExportPallet(), 2);
      await source.clearBarcodes();
      expect(await source.startNewExportPallet(), 1);
    },
  );

  test('failed scan write rolls back the counter', () async {
    await source.startNewExportPallet();
    await db.execute(
      "CREATE TRIGGER fail_insert BEFORE INSERT ON barcodes BEGIN SELECT RAISE(ABORT, 'test failure'); END",
    );
    await expectLater(
      source.saveBarcode(const ItemBox(exportPalletNo: 1)),
      throwsA(isA<DatabaseException>()),
    );
    expect(await source.getCurrentExportPalletNo(), 1);
    expect(await source.getBarcodes(), isEmpty);
    await expectLater(
      source.startNewExportPallet(),
      throwsA(isA<EmptyPalletException>()),
    );
  });

  test('a scanned full pallet permits starting the first box pallet', () async {
    await source.saveBarcode(const ItemBox(isPallet: true, exportPalletNo: 1));
    expect(await source.startNewExportPallet(), 2);
    await expectLater(
      source.startNewExportPallet(),
      throwsA(isA<EmptyPalletException>()),
    );
  });

  test('switching to full pallet scans cannot skip an empty group', () async {
    await source.startNewExportPallet();
    await expectLater(source.saveBarcode(const ItemBox(isPallet: true, exportPalletNo: 2)), throwsA(isA<EmptyPalletException>()));
    expect(await source.getCurrentExportPalletNo(), 1);
    expect(await source.getBarcodes(), isEmpty);
    await source.saveBarcode(const ItemBox(exportPalletNo: 1));
    await source.saveBarcode(const ItemBox(isPallet: true, exportPalletNo: 2));
    expect(await source.getCurrentExportPalletNo(), 2);
  });

  test('counter recovers from stored numbered rows', () async {
    await source.saveBarcode(const ItemBox(exportPalletNo: 8));
    await db.update('inventory_session', {'currentExportPalletNo': 0});
    expect(await source.getCurrentExportPalletNo(), 8);
    expect(await source.startNewExportPallet(), 9);
  });

  test('v3 upgrade preserves records with blank export numbers', () async {
    await db.execute('DROP TABLE barcodes');
    await db.execute('DROP TABLE inventory_session');
    await db.execute(
      'CREATE TABLE barcodes (id INTEGER PRIMARY KEY AUTOINCREMENT, barCodeNo TEXT, matnr TEXT, batchNo TEXT, serialNo TEXT, palletBox TEXT, qty INTEGER, isPallet INTEGER, isSent INTEGER DEFAULT 0)',
    );
    await db.insert('barcodes', {
      'barCodeNo': '12345600000000010001',
      'matnr': '123456',
      'batchNo': '0000000001',
      'serialNo': '0001',
      'palletBox': 'B',
      'qty': 1,
      'isPallet': 0,
      'isSent': 1,
    });
    await upgradeInventorySchema(db, 3, 4);
    final rows = await source.getBarcodes();
    expect(rows, hasLength(1));
    expect(rows.single.batchNo, '0000000001');
    expect(rows.single.isSent, true);
    expect(rows.single.exportPalletNo, isNull);
    expect(await source.startNewExportPallet(), 1);
  });

  test('upgrade handles a missing legacy barcode table', () async {
    await db.execute('DROP TABLE barcodes');
    await db.execute('DROP TABLE inventory_session');
    await upgradeInventorySchema(db, 1, 4);
    await source.saveBarcode(const ItemBox(exportPalletNo: 1));
    expect((await source.getBarcodes()).single.exportPalletNo, 1);
  });
}
