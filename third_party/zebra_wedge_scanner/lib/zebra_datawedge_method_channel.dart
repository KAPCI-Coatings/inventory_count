import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'zebra_datawedge_platform_interface.dart';

/// Method channel implementation of [ZebraDataWedgePlatform].
///
/// This class communicates with the native Android platform using
/// [MethodChannel] for commands and [EventChannel] for scan events.
class MethodChannelZebraDataWedgePlatform extends ZebraDataWedgePlatform {
  /// The method channel for invoking platform methods.
  @visibleForTesting
  final MethodChannel methodChannel =
      const MethodChannel('zebra_datawedge/methods');

  /// The event channel for receiving scan events from the platform.
  @visibleForTesting
  final EventChannel eventChannel =
      const EventChannel('zebra_datawedge/scans');

  @override
  Stream<Map<String, dynamic>> get events {
    return eventChannel
        .receiveBroadcastStream()
        .map<Map<String, dynamic>>((dynamic event) {
      if (event is Map) {
        return Map<String, dynamic>.from(event);
      }
      return <String, dynamic>{'type': 'scan', 'data': event?.toString() ?? ''};
    });
  }

  @override
  Future<bool> isDataWedgeAvailable() async {
    final bool? available =
        await methodChannel.invokeMethod<bool>('isDataWedgeAvailable');
    return available ?? false;
  }

  @override
  Future<void> configureProfile(String profileName) {
    return methodChannel.invokeMethod<void>(
      'configureProfile',
      <String, dynamic>{'profileName': profileName},
    );
  }

  @override
  Future<void> switchToProfile(String profileName) {
    return methodChannel.invokeMethod<void>(
      'switchToProfile',
      <String, dynamic>{'profileName': profileName},
    );
  }

  @override
  Future<void> startSoftScan() {
    return methodChannel.invokeMethod<void>('startSoftScan');
  }

  @override
  Future<void> enableScanner() {
    return methodChannel.invokeMethod<void>('enableScanner');
  }

  @override
  Future<void> disableScanner() {
    return methodChannel.invokeMethod<void>('disableScanner');
  }

  @override
  Future<void> registerForNotification(String notificationType) {
    return methodChannel.invokeMethod<void>(
      'registerForNotification',
      <String, dynamic>{'notificationType': notificationType},
    );
  }

  @override
  Future<void> unregisterForNotification(String notificationType) {
    return methodChannel.invokeMethod<void>(
      'unregisterForNotification',
      <String, dynamic>{'notificationType': notificationType},
    );
  }

  @override
  Future<void> getActiveProfile() {
    return methodChannel.invokeMethod<void>('getActiveProfile');
  }

  @override
  Future<void> getProfilesList() {
    return methodChannel.invokeMethod<void>('getProfilesList');
  }

  @override
  Future<void> getVersionInfo() {
    return methodChannel.invokeMethod<void>('getVersionInfo');
  }

  @override
  Future<void> enumerateScanners() {
    return methodChannel.invokeMethod<void>('enumerateScanners');
  }

  @override
  Future<void> sendCommand({
    required String command,
    dynamic value,
    String? commandTag,
    bool requestResult = true,
  }) {
    return methodChannel.invokeMethod<void>(
      'sendCommand',
      <String, dynamic>{
        'command': command,
        'value': value,
        'commandTag': commandTag,
        'requestResult': requestResult,
      },
    );
  }

  @override
  Future<void> sendCommandBundle({
    required String command,
    required Map<String, dynamic> value,
    String? commandTag,
    bool requestResult = true,
  }) {
    return methodChannel.invokeMethod<void>(
      'sendCommandBundle',
      <String, dynamic>{
        'command': command,
        'value': value,
        'commandTag': commandTag,
        'requestResult': requestResult,
      },
    );
  }

  @override
  Future<void> sendIntent({
    required Map<String, dynamic> extras,
    String? action,
    String? targetPackage,
    String? commandTag,
    bool requestResult = true,
    bool orderedBroadcast = false,
    bool includeApplicationPackage = false,
  }) {
    return methodChannel.invokeMethod<void>(
      'sendIntent',
      <String, dynamic>{
        'extras': extras,
        'action': action,
        'targetPackage': targetPackage,
        'commandTag': commandTag,
        'requestResult': requestResult,
        'orderedBroadcast': orderedBroadcast,
        'includeApplicationPackage': includeApplicationPackage,
      },
    );
  }
}
