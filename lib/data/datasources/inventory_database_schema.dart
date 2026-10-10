import 'package:sqflite/sqflite.dart';

Future<void> createInventorySchema(Database db) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS barcodes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      barCodeNo TEXT, matnr TEXT, batchNo TEXT, serialNo TEXT,
      palletBox TEXT, qty INTEGER, isPallet INTEGER,
      isSent INTEGER DEFAULT 0, exportPalletNo INTEGER
    )
  ''');
  final columns = await db.rawQuery('PRAGMA table_info(barcodes)');
  for (final column in {
    'isSent': 'INTEGER DEFAULT 0',
    'exportPalletNo': 'INTEGER',
  }.entries) {
    if (!columns.any((row) => row['name'] == column.key)) {
      await db.execute(
        'ALTER TABLE barcodes ADD COLUMN ${column.key} ${column.value}',
      );
    }
  }
  await db.execute('''
    CREATE TABLE IF NOT EXISTS inventory_session (
      id INTEGER PRIMARY KEY CHECK (id = 1),
      currentExportPalletNo INTEGER NOT NULL DEFAULT 0
    )
  ''');
  await db.rawInsert(
    'INSERT OR IGNORE INTO inventory_session (id, currentExportPalletNo) VALUES (1, 0)',
  );
}

Future<void> upgradeInventorySchema(
  Database db,
  int oldVersion,
  int newVersion,
) async {
  // Retain the pre-v2 migration; v3 inventory is always preserved.
  if (oldVersion < 2) await db.execute('DROP TABLE IF EXISTS barcodes');
  await createInventorySchema(db);
}
