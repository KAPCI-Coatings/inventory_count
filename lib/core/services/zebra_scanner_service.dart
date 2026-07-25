import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:zebra_wedge_scanner/zebra_datawedge.dart';

import 'scanner_service.dart';

/// Concrete implementation of [ScannerService] built on top of the
/// `zebra_wedge_scanner` package.
///
/// This class is the ONLY place in the project that knows about
/// `ZebraDataWedge`. Every other part of the app depends solely on
/// [ScannerService].
///
/// If you ever need to swap the package (e.g. for a different scanner brand
/// or a mock during testing), you simply create a new class that implements
/// [ScannerService] and update the DI registration in `di.dart`.
///
/// ──────────────────────────────────────────────────────────────────────────
/// Initialisation order
/// ──────────────────────────────────────────────────────────────────────────
///   1. Register this service in GetIt (di.dart) as a lazy singleton.
///   2. Call [initialize] once at app start (or at the first screen that
///      needs scanning).
///   3. Listen to [onScan] / [onStatusChange] wherever you need events.
///   4. Use [enableScanner] / [disableScanner] to gate scanning per screen.
///   5. Call [dispose] when shutting down.
class ZebraScannerService with WidgetsBindingObserver implements ScannerService {
  ZebraScannerService({
    required this.androidPackageName,
    this.profileName = 'KAPCI_INVENTORY_PROFILE',
  });

  /// Your Android applicationId (e.g. 'com.kapci.inventory_count').
  final String androidPackageName;

  /// DataWedge profile name that will be created / updated on init.
  final String profileName;

  // ── Private fields ────────────────────────────────────────────────────────

  final ZebraDataWedge _dw = ZebraDataWedge();

  final StreamController<ScanResult> _scanController =
      StreamController<ScanResult>.broadcast();

  final StreamController<ScannerStatus> _statusController =
      StreamController<ScannerStatus>.broadcast();

  StreamSubscription<DataWedgeEvent>? _eventSub;

  bool _initialised = false;
  bool _scannerEnabled = false;

  // ── ScannerService interface ──────────────────────────────────────────────

  @override
  Stream<ScanResult> get onScan => _scanController.stream;

  @override
  Stream<ScannerStatus> get onStatusChange => _statusController.stream;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  Future<void> initialize() async {
    if (_initialised) return;

    debugPrint('[ZebraScannerService] ====== STARTING INITIALIZATION ======');

    // 1. Verify device support
    final bool available = await _dw.isAvailable();
    debugPrint('[ZebraScannerService] DataWedge available: $available');
    if (!available) {
      _statusController.add(ScannerStatus.unavailable);
      throw const ScannerUnavailableException(
        'DataWedge is not available on this device. '
        'This app requires a Zebra device with DataWedge installed.',
      );
    }

    // 2. Subscribe to the event streams FIRST.
    // This triggers EventChannel.onListen in Kotlin, which registers the
    // BroadcastReceiver BEFORE DataWedge starts sending intents.
    _dw.scanStream.listen((Map<String, dynamic> rawEvent) {
      debugPrint('[ZebraScannerService] ★★★ RAW EVENT: $rawEvent');
    });

    _eventSub = _dw.events.listen(
      (DataWedgeEvent event) {
        debugPrint('[ZebraScannerService] ▶ EVENT type=${event.type}, isScan=${event.isScan}');
        _handleEvent(event);
      },
      onError: _handleStreamError,
    );
    debugPrint('[ZebraScannerService] Subscribed to event stream');

    // 3. Configure the DataWedge profile manually with OVERWRITE mode.
    // Overwrite mode fixes the "APP_ALREADY_ASSOCIATED" error by replacing
    // any existing corrupt profile.
    final configuration = DataWedgeProfileBuilder(
      profileName: profileName,
      configMode: DataWedgeConfigMode.overwrite, // CRITICAL: OVERWRITE
    )
        .setProfileEnabled(true)
        .addPlugin(
          DataWedgePluginConfiguration(
            pluginName: DataWedgePluginName.barcode,
            resetConfig: true,
            paramList: <String, dynamic>{
              'scanner_selection': 'auto',
              'scanner_selection_by_identifier': DataWedgeScannerIdentifier.auto,
              'scanner_input_enabled': dataWedgeBool(true),
            },
          ),
        )
        .addPlugin(
          DataWedgePluginConfiguration(
            pluginName: DataWedgePluginName.intent,
            resetConfig: true,
            paramList: <String, dynamic>{
              'intent_output_enabled': dataWedgeBool(true),
              'intent_action': '$androidPackageName.SCAN',
              'intent_category': DataWedgeApi.defaultIntentCategory,
              'intent_delivery': DataWedgeIntentDelivery.broadcast,
            },
          ),
        )
        .addPlugin(
          DataWedgePluginConfiguration(
            pluginName: DataWedgePluginName.keystroke,
            resetConfig: true,
            paramList: <String, dynamic>{
              'keystroke_output_enabled': dataWedgeBool(false),
            },
          ),
        )
        .addAppAssociation(
          DataWedgeAppAssociation(
            packageName: androidPackageName,
            activityList: const <String>[DataWedgeApi.wildcard],
          ),
        )
        .build();

    await _dw.setConfig(configuration);
    debugPrint('[ZebraScannerService] Profile configured with OVERWRITE: $profileName');

    // 4. Force DataWedge to switch to our profile.
    await _dw.switchToProfile(profileName);
    debugPrint('[ZebraScannerService] Switched to profile: $profileName');

    // 5. Give DataWedge time to apply, then disable scanner
    // so it doesn't fire on splash/login screens.
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      await _dw.disableScanner();
      debugPrint('[ZebraScannerService] Successfully sent initial DISABLE_PLUGIN');
    } catch (e) {
      debugPrint('[ZebraScannerService] Warning: Could not disable scanner initially: $e');
    }

    WidgetsBinding.instance.addObserver(this);
    _initialised = true;
    _statusController.add(ScannerStatus.disabled);
    debugPrint('[ZebraScannerService] ====== INITIALIZATION COMPLETE ======');
  }

  @override
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    await _eventSub?.cancel();
    await _scanController.close();
    await _statusController.close();
    _initialised = false;
    debugPrint('[ZebraScannerService] Disposed');
  }

  // ── Availability ──────────────────────────────────────────────────────────

  @override
  Future<bool> isAvailable() => _dw.isAvailable();

  // ── Scanner control ───────────────────────────────────────────────────────

  @override
  Future<void> enableScanner() async {
    _assertInitialised();
    _scannerEnabled = true;
    try {
      await _dw.enableScanner();
      debugPrint('[ZebraScannerService] Scanner enabled');
    } catch (e) {
      throw ScannerOperationException('Failed to enable scanner', cause: e);
    }
  }

  @override
  Future<void> disableScanner() async {
    _assertInitialised();
    _scannerEnabled = false;
    try {
      await _dw.disableScanner();
      _statusController.add(ScannerStatus.disabled);
      debugPrint('[ZebraScannerService] Scanner disabled');
    } catch (e) {
      throw ScannerOperationException('Failed to disable scanner', cause: e);
    }
  }

  @override
  Future<void> suspendScanner() async {
    _assertInitialised();
    try {
      await _dw.suspendScanner();
      _statusController.add(ScannerStatus.suspended);
      debugPrint('[ZebraScannerService] Scanner suspended');
    } catch (e) {
      throw ScannerOperationException('Failed to suspend scanner', cause: e);
    }
  }

  @override
  Future<void> resumeScanner() async {
    _assertInitialised();
    try {
      await _dw.resumeScanner();
      _statusController.add(ScannerStatus.idle);
      debugPrint('[ZebraScannerService] Scanner resumed');
    } catch (e) {
      throw ScannerOperationException('Failed to resume scanner', cause: e);
    }
  }

  // ── Soft trigger ──────────────────────────────────────────────────────────

  @override
  Future<void> startSoftScan() async {
    _assertInitialised();
    try {
      await _dw.startSoftScan();
      _statusController.add(ScannerStatus.scanning);
    } catch (e) {
      throw ScannerOperationException('Failed to start soft scan', cause: e);
    }
  }

  @override
  Future<void> stopSoftScan() async {
    _assertInitialised();
    try {
      await _dw.stopSoftScan();
      _statusController.add(ScannerStatus.idle);
    } catch (e) {
      throw ScannerOperationException('Failed to stop soft scan', cause: e);
    }
  }

  @override
  Future<void> toggleSoftScan() async {
    _assertInitialised();
    try {
      await _dw.toggleSoftScan();
    } catch (e) {
      throw ScannerOperationException('Failed to toggle soft scan', cause: e);
    }
  }

  // ── Profile management ────────────────────────────────────────────────────

  @override
  Future<void> switchToProfile(String name) async {
    _assertInitialised();
    try {
      await _dw.switchToProfile(name);
      debugPrint('[ZebraScannerService] Switched to profile: $name');
    } catch (e) {
      throw ScannerOperationException('Failed to switch profile to $name', cause: e);
    }
  }

  @override
  Future<void> getActiveProfile() async {
    _assertInitialised();
    try {
      await _dw.getActiveProfile();
    } catch (e) {
      throw ScannerOperationException('Failed to get active profile', cause: e);
    }
  }

  // ── DataWedge service ─────────────────────────────────────────────────────

  @override
  Future<void> setDataWedgeEnabled({required bool enabled}) async {
    _assertInitialised();
    try {
      await _dw.setDataWedgeEnabled(enabled);
      debugPrint('[ZebraScannerService] DataWedge ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      throw ScannerOperationException(
        'Failed to ${enabled ? 'enable' : 'disable'} DataWedge',
        cause: e,
      );
    }
  }

  @override
  Future<void> getScannerStatus() async {
    _assertInitialised();
    try {
      await _dw.getScannerStatus();
    } catch (e) {
      throw ScannerOperationException('Failed to get scanner status', cause: e);
    }
  }

  // ── Internal event handling ───────────────────────────────────────────────

  String? _lastScanData;
  DateTime? _lastScanTime;

  void _handleEvent(DataWedgeEvent event) {
    if (event.isScan) {
      final String? data = event.scanData;
      final String? label = event.labelType;

      if (data != null && data.isNotEmpty) {
        final now = DateTime.now();

        // Hardware scanners can sometimes emit multiple broadcast intents for 
        // a single physical button press. Debounce identical scans within 500ms.
        if (_lastScanData == data &&
            _lastScanTime != null &&
            now.difference(_lastScanTime!).inMilliseconds < 500) {
          debugPrint(
            '[ZebraScannerService] Ignored duplicate hardware scan within 500ms: $data',
          );
          return;
        }

        _lastScanData = data;
        _lastScanTime = now;

        _scanController.add(
          ScanResult(
            data: data,
            labelType: label ?? 'UNKNOWN',
            timestamp: now.toUtc(),
          ),
        );
        _statusController.add(ScannerStatus.idle);
        debugPrint('[ZebraScannerService] Scan received: $data ($label)');
      }
      return;
    }

    if (event.isNotification) {
      _handleNotification(event);
      return;
    }

    if (event.isCommandResult) {
      final String cmd = event.command ?? '';
      final String res = event.result ?? '';
      debugPrint('[ZebraScannerService] Command result: $cmd -> $res');
      if (res.toLowerCase() == 'failure') {
        debugPrint(
          '[ZebraScannerService] ⚠️  Command "$cmd" failed — '
          'consider switching the scanner package or reconfiguring the profile.',
        );
      }
    }
  }

  void _handleNotification(DataWedgeEvent event) {
    final String? type = event.notificationType;
    final String? status = event.scannerStatus;

    debugPrint('[ZebraScannerService] Notification: $type -> $status');

    if (type == DataWedgeNotificationType.scannerStatus) {
      switch (status?.toUpperCase()) {
        case 'SCANNING':
          _statusController.add(ScannerStatus.scanning);
        case 'IDLE':
        case 'CONNECTED':
        case 'WAITING':
          _statusController.add(ScannerStatus.idle);
        case 'DISABLED':
          _statusController.add(ScannerStatus.disabled);
        case 'SUSPENDED':
          _statusController.add(ScannerStatus.suspended);
        default:
          _statusController.add(ScannerStatus.unknown);
      }
    }
  }

  void _handleStreamError(Object error, StackTrace stackTrace) {
    debugPrint('[ZebraScannerService] Stream error: $error\n$stackTrace');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_initialised) return;

    if (state == AppLifecycleState.resumed) {
      if (_scannerEnabled) {
        debugPrint('[ZebraScannerService] App resumed — restoring hardware scanner state');
        _dw.switchToProfile(profileName).then((_) {
          return _dw.enableScanner();
        }).catchError((e) {
          debugPrint('[ZebraScannerService] Failed to restore hardware scanner on resume: $e');
        });
      }
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (_scannerEnabled) {
        debugPrint('[ZebraScannerService] App paused/inactive — suspending hardware scanner');
        _dw.disableScanner().catchError((e) {
          debugPrint('[ZebraScannerService] Failed to suspend hardware scanner on pause: $e');
        });
      }
    }
  }

  // ── Guard ─────────────────────────────────────────────────────────────────

  void _assertInitialised() {
    if (!_initialised) {
      throw StateError(
        'ZebraScannerService is not initialised. '
        'Call initialize() before using any scanner methods.',
      );
    }
  }
}
