import 'package:inventory_count_flutter_app/domain/entities/scan_item.dart';
import 'package:inventory_count_flutter_app/domain/entities/scanner_cache.dart';
import 'package:inventory_count_flutter_app/domain/entities/scanner_settings.dart';

import '../entities/item_box.dart';

abstract class ScannerRepository {
  Future<void> initialize();
  Stream<ScanItem> observeScans();

  Future<void> enableScanner();
  Future<void> disableScanner();
  Future<void> switchProfile(String profileName);

  Future<ScannerSettings> getSettings();
  Future<void> saveSettings(ScannerSettings settings);

  Future<ScannerCache> loadScannerCache();
  Future<void> saveScannerCache(ScannerCache cache);
  Future<void> clearScannerCache();

  Future<void> postHandlingDetails({
    required String baseUrl,
    required int devId,
    required List<ItemBox> itemBoxes,
  });
}
