import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'zebra_datawedge_method_channel.dart';

/// Platform interface for the Zebra DataWedge plugin.
///
/// This abstract class defines the contract that all platform implementations
/// must follow. The default implementation uses method channels for Android.
///
/// To implement a custom platform (e.g., for testing or a new platform),
/// extend this class and set [ZebraDataWedgePlatform.instance] to your
/// implementation before using [ZebraDataWedge].
abstract class ZebraDataWedgePlatform extends PlatformInterface {
  /// Creates a new platform interface instance.
  ZebraDataWedgePlatform() : super(token: _token);

  static final Object _token = Object();

  static ZebraDataWedgePlatform _instance = MethodChannelZebraDataWedgePlatform();

  /// The current platform implementation instance.
  static ZebraDataWedgePlatform get instance => _instance;

  /// Sets the platform implementation instance.
  ///
  /// This is typically used for testing or custom platform implementations.
  static set instance(ZebraDataWedgePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// A stream of raw events from the DataWedge service.
  ///
  /// Each event is a Map containing the event data. Use [ZebraDataWedge.events]
  /// for typed events.
  Stream<Map<String, dynamic>> get events {
    throw UnimplementedError('events has not been implemented.');
  }

  /// Checks if DataWedge is available on the device.
  ///
  /// Returns `true` if DataWedge is installed and available.
  Future<bool> isDataWedgeAvailable() {
    throw UnimplementedError('isDataWedgeAvailable() has not been implemented.');
  }

  /// Creates or updates a DataWedge profile.
  Future<void> configureProfile(String profileName) {
    throw UnimplementedError('configureProfile() has not been implemented.');
  }

  /// Switches to the specified profile.
  Future<void> switchToProfile(String profileName) {
    throw UnimplementedError('switchToProfile() has not been implemented.');
  }

  /// Starts a software scan trigger.
  Future<void> startSoftScan() {
    throw UnimplementedError('startSoftScan() has not been implemented.');
  }

  /// Enables the scanner.
  Future<void> enableScanner() {
    throw UnimplementedError('enableScanner() has not been implemented.');
  }

  /// Disables the scanner.
  Future<void> disableScanner() {
    throw UnimplementedError('disableScanner() has not been implemented.');
  }

  /// Registers for notifications of the specified type.
  Future<void> registerForNotification(String notificationType) {
    throw UnimplementedError('registerForNotification() has not been implemented.');
  }

  /// Unregisters from notifications of the specified type.
  Future<void> unregisterForNotification(String notificationType) {
    throw UnimplementedError('unregisterForNotification() has not been implemented.');
  }

  /// Retrieves the active profile name.
  Future<void> getActiveProfile() {
    throw UnimplementedError('getActiveProfile() has not been implemented.');
  }

  /// Retrieves the list of all profiles.
  Future<void> getProfilesList() {
    throw UnimplementedError('getProfilesList() has not been implemented.');
  }

  /// Retrieves the DataWedge version info.
  Future<void> getVersionInfo() {
    throw UnimplementedError('getVersionInfo() has not been implemented.');
  }

  /// Enumerates all available scanners.
  Future<void> enumerateScanners() {
    throw UnimplementedError('enumerateScanners() has not been implemented.');
  }

  /// Sends a command to DataWedge.
  ///
  /// [command] is the DataWedge API command string.
  /// [value] is the command parameter.
  /// [commandTag] optionally identifies this command in result events.
  /// [requestResult] when true, a result event will be emitted.
  Future<void> sendCommand({
    required String command,
    dynamic value,
    String? commandTag,
    bool requestResult = true,
  }) {
    throw UnimplementedError('sendCommand() has not been implemented.');
  }

  /// Sends a command with a Map value to DataWedge.
  Future<void> sendCommandBundle({
    required String command,
    required Map<String, dynamic> value,
    String? commandTag,
    bool requestResult = true,
  }) {
    throw UnimplementedError('sendCommandBundle() has not been implemented.');
  }

  /// Sends an intent to DataWedge or another package.
  Future<void> sendIntent({
    required Map<String, dynamic> extras,
    String? action,
    String? targetPackage,
    String? commandTag,
    bool requestResult = true,
    bool orderedBroadcast = false,
    bool includeApplicationPackage = false,
  }) {
    throw UnimplementedError('sendIntent() has not been implemented.');
  }
}
