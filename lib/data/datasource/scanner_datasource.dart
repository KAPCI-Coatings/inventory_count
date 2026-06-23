import 'dart:convert';

import 'package:inventory_count_flutter_app/domain/entities/scanner_cache.dart';
import 'package:inventory_count_flutter_app/domain/entities/scanner_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ScannerPrefsDataSource {
  Future<ScannerSettings> loadSettings();
  Future<void> saveSettings(ScannerSettings settings);
  Future<ScannerCache> loadScannerCache();
  Future<void> saveScannerCache(ScannerCache cache);
  Future<void> clearScannerCache();
}

class ScannerDataSourceImpl implements ScannerPrefsDataSource {
  static const String _profileNameKey = 'scanner.profile_name';
  static const String _baseUrlKey = 'scanner.base_url';
  static const String _deviceIdKey = 'scanner.device_id';
  static const String _scannerCacheKey = 'scanner.cache.v2';

  final SharedPreferences _prefs;

  ScannerDataSourceImpl(this._prefs);

  @override
  Future<ScannerSettings> loadSettings() async {
    final ScannerSettings defaults = ScannerSettings.defaults();

    final String profile =
        _prefs.getString(_profileNameKey) ?? defaults.profileName;
    final String? storedBaseUrl = _prefs.getString(_baseUrlKey);
    String baseUrl = storedBaseUrl ?? defaults.baseUrl;
  
    final int deviceId = _prefs.getInt(_deviceIdKey) ?? defaults.deviceId;

    return ScannerSettings(
      profileName: profile,
      baseUrl: baseUrl,
      deviceId: deviceId,
    );
  }

  @override
  Future<void> saveSettings(ScannerSettings settings) async {
    final bool profileSaved = await _prefs.setString(
      _profileNameKey,
      settings.profileName,
    );
    final bool baseUrlSaved = await _prefs.setString(
      _baseUrlKey,
      settings.baseUrl,
    );
    final bool deviceIdSaved = await _prefs.setInt(
      _deviceIdKey,
      settings.deviceId,
    );

    if (!profileSaved || !baseUrlSaved || !deviceIdSaved) {
      throw StateError('تعذر حفظ إعدادات الماسح في التخزين المحلي.');
    }
  }

  @override
  Future<ScannerCache> loadScannerCache() async {
    final String? rawJson = _prefs.getString(_scannerCacheKey);
    if (rawJson == null || rawJson.trim().isEmpty) {
      return const ScannerCache();
    }

    try {
      final dynamic decoded = jsonDecode(rawJson);
      if (decoded is! Map<String, dynamic>) {
        return const ScannerCache();
      }
      return ScannerCache.fromJson(decoded);
    } catch (_) {
      return const ScannerCache();
    }
  }

  @override
  Future<void> saveScannerCache(ScannerCache cache) async {
    final String encoded = jsonEncode(cache.toJson());
    await _prefs.setString(_scannerCacheKey, encoded);
  }

  @override
  Future<void> clearScannerCache() async {
    await _prefs.remove(_scannerCacheKey);
  }
}
