import 'package:inventory_count_flutter_app/domain/entities/asset_scan.dart';
import 'package:sqflite/sqflite.dart';

abstract class AssetLocalDataSource {
  Future<void> saveAssetScan(AssetScan scan);
  Future<List<AssetScan>> getAssetScans();
  Future<int> getAssetCount();
  Future<void> clearAssetScans();
}

class AssetLocalDataSourceImpl implements AssetLocalDataSource {
  final Database database;

  AssetLocalDataSourceImpl(this.database);

  @override
  Future<void> saveAssetScan(AssetScan scan) async {
    await database.insert('asset_scans', scan.toMap());
  }

  @override
  Future<List<AssetScan>> getAssetScans() async {
    final List<Map<String, dynamic>> maps =
        await database.query('asset_scans', orderBy: 'scannedAt DESC');
    return maps.map((m) => AssetScan.fromMap(m)).toList();
  }

  @override
  Future<int> getAssetCount() async {
    final result = await database.rawQuery('SELECT COUNT(*) FROM asset_scans');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<void> clearAssetScans() async {
    await database.delete('asset_scans');
  }
}
