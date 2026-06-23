import 'package:inventory_count_flutter_app/domain/entities/scan_item.dart';
import 'package:inventory_count_flutter_app/domain/entities/scanner_cache.dart';
import 'package:inventory_count_flutter_app/domain/entities/scanner_settings.dart';

import '../../domain/entities/item_box.dart';
import '../../domain/repositories/scanner_repository.dart';
import '../datasource/datawedge_datasource.dart';
import '../datasource/scanner_datasource.dart';
import '../datasource/scanner_remote_datasource.dart';

class ScannerRepositoryImpl implements ScannerRepository {
  final DataWedgeDataSource _dwDataSource;
  final ScannerPrefsDataSource _prefsDataSource;
  final ScannerRemoteDataSource _remoteDataSource;

  ScannerRepositoryImpl({
    required DataWedgeDataSource dwDataSource,
    required ScannerPrefsDataSource prefsDataSource,
    required ScannerRemoteDataSource remoteDataSource,
  }) : _dwDataSource = dwDataSource,
       _prefsDataSource = prefsDataSource,
       _remoteDataSource = remoteDataSource;

  @override
  Future<void> initialize() async {
    ScannerSettings settings = await _prefsDataSource.loadSettings();
    // Fallback to default profile if stored name is empty.
    if (settings.profileName.trim().isEmpty) {
      settings = ScannerSettings.defaults();
      await _prefsDataSource.saveSettings(settings);
    }

    await _dwDataSource.initializeProfile(profileName: settings.profileName);

    // Ensure scanner plugin is enabled after profile initialization.
    await _dwDataSource.enableScanner();
  }

  @override
  Stream<ScanItem> observeScans() {
    return _dwDataSource
        .events()
        .where((event) => event.isScan)
        .map((event) => (event.scanData ?? '').trim())
        .where((code) => code.isNotEmpty)
        .map(
          (code) => ScanItem(code: code, scannedAt: DateTime.now()),
        );
  }

  @override
  Future<void> enableScanner() => _dwDataSource.enableScanner();

  @override
  Future<void> disableScanner() => _dwDataSource.disableScanner();

  @override
  Future<void> switchProfile(String profileName) async {
    final String nextProfile = profileName.trim();
    if (nextProfile.isEmpty) {
      throw ArgumentError.value(
        profileName,
        'profileName',
        'Profile name cannot be empty',
      );
    }

    await _dwDataSource.switchProfile(nextProfile);

    final ScannerSettings currentSettings = await _prefsDataSource.loadSettings();

    await _prefsDataSource.saveSettings(
      ScannerSettings(
        profileName: nextProfile,
        baseUrl: currentSettings.baseUrl,
        deviceId: currentSettings.deviceId,
      ),
    );
  }

  @override
  Future<ScannerSettings> getSettings() => _prefsDataSource.loadSettings();

  @override
  Future<void> saveSettings(ScannerSettings settings) =>
      _prefsDataSource.saveSettings(settings);

  @override
  Future<ScannerCache> loadScannerCache() => _prefsDataSource.loadScannerCache();

  @override
  Future<void> saveScannerCache(ScannerCache cache) =>
      _prefsDataSource.saveScannerCache(cache);

  @override
  Future<void> clearScannerCache() => _prefsDataSource.clearScannerCache();

  @override
  Future<void> postHandlingDetails({
    required String baseUrl,
    required int devId,
    required List<ItemBox> itemBoxes,
  }) {
    return _remoteDataSource.postHandlingDetails(
      baseUrl: baseUrl,
      devId: devId,
      itemBoxes: itemBoxes,
    );
  }
}
