import 'package:shared_preferences/shared_preferences.dart';

abstract class SettingsLocalDataSource {
  Future<void> saveDevId(String id);
  String? getDevId();
  Future<void> saveBaseUrl(String url);
  String? getBaseUrl();
  Future<void> saveLanguage(String locale);
  String? getLanguage();
  Future<void> saveDataType(String type);
  String? getDataType();
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final SharedPreferences _prefs;

  static const String _keyDevId = 'settings_dev_id';
  static const String _keyBaseUrl = 'settings_base_url';
  static const String _keyLanguage = 'settings_language';
  static const String _keyDataType = 'settings_data_type';

  SettingsLocalDataSourceImpl(this._prefs);

  @override
  Future<void> saveDevId(String id) async {
    await _prefs.setString(_keyDevId, id);
  }

  @override
  String? getDevId() {
    return _prefs.getString(_keyDevId);
  }

  @override
  Future<void> saveBaseUrl(String url) async {
    await _prefs.setString(_keyBaseUrl, url);
  }

  @override
  String? getBaseUrl() {
    return _prefs.getString(_keyBaseUrl);
  }

  @override
  Future<void> saveLanguage(String locale) async {
    await _prefs.setString(_keyLanguage, locale);
  }

  @override
  String? getLanguage() {
    return _prefs.getString(_keyLanguage);
  }

  @override
  Future<void> saveDataType(String type) async {
    await _prefs.setString(_keyDataType, type);
  }

  @override
  String? getDataType() {
    return _prefs.getString(_keyDataType);
  }
}
