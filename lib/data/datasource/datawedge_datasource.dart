import 'package:zebra_wedge_scanner/zebra_datawedge.dart';

abstract class DataWedgeDataSource {
  Future<void> initializeProfile({required String profileName});

  Stream<DataWedgeEvent> events();
  Future<void> enableScanner();
  Future<void> disableScanner();
  Future<void> switchProfile(String profileName);
}

class DataWedgeDataSourceImpl implements DataWedgeDataSource {
  final ZebraDataWedge _dw;

  DataWedgeDataSourceImpl(this._dw);

  @override
  Future<void> initializeProfile({required String profileName}) async {
    final String trimmedName = profileName.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError.value(
        profileName,
        'profileName',
        'Profile name cannot be empty',
      );
    }
    final bool available = await _dw.isAvailable();
    if (!available) {
      throw Exception('DataWedge is not available on this device');
    }

    // Configure profile using plugin's native runtime package resolution.
    await _dw.configureProfile(trimmedName);

    await _dw.switchToProfile(trimmedName);
    await _dw.registerForDefaultNotifications();
  }

  @override
  Stream<DataWedgeEvent> events() => _dw.events;

  @override
  Future<void> enableScanner() => _dw.enableScanner();

  @override
  Future<void> disableScanner() => _dw.disableScanner();

  @override
  Future<void> switchProfile(String profileName) async {
    final String trimmedName = profileName.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError.value(
        profileName,
        'profileName',
        'Profile name cannot be empty',
      );
    }
    await _dw.switchToProfile(trimmedName);
  }
}
