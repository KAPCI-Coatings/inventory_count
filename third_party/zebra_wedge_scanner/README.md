# Zebra_Datawedge_With_Flutter

Flutter plugin that works with Zebra DataWedge on compatible Zebra Android devices.

This README is written for beginners and junior Flutter developers.
It explains what each major part of the package does and how to use it in a real app.

## Table of Contents

- What This Package Does
- Core Concepts You Must Know
- Platform and Device Requirements
- Installation
- First Working Integration (Step-by-Step)
- Understanding Events and Payloads
- Profile Setup in Depth
- API Guide by Use Case
- Reliable Command Handling Pattern
- Advanced Examples
- Troubleshooting Guide
- License
- Legal and Trademark Notice
- Pub.dev Publishing Checklist
- References

## What This Package Does

Zebra devices use a system service called DataWedge for scanning and data capture.
Instead of writing Android broadcast intent code manually, this package gives you:

- A clean Flutter API through `ZebraDataWedge`.
- Strongly typed constants and request models.
- Generic command methods for future DataWedge APIs.
- A unified event stream for:
  - Scan data
  - Command results
  - Notifications
  - Debug messages

In simple terms:

- You send commands from Flutter to DataWedge.
- DataWedge executes them.
- Your app receives scan events and status events.

## Core Concepts You Must Know

Before coding, learn these 4 terms:

1. Profile
   A DataWedge profile is a configuration set (scanner settings, output mode, app binding).

2. App association
   The profile must be associated with your app package, or your app will not receive scans.

3. Intent output
   DataWedge sends scan data as Android intents. This plugin listens and forwards them to Flutter.

4. Command result
   Most commands can return success/failure info. You should listen to command result events for reliability.

## Platform and Device Requirements

- Android only
- Zebra devices with DataWedge installed
- Flutter SDK >= 3.3.0
- Dart SDK compatible with package constraints

Important:

- Feature availability depends on DataWedge version and hardware model.
- Some APIs (workflow, RFID, scale, scanner switching) are device-specific.

## Installation

### Install from Pub.dev (recommended)

Add this to your app `pubspec.yaml`:

```yaml
dependencies:
  zebra_datawedge: ^0.1.4
```

Then run:

```bash
flutter pub get
```

### Local path install (for plugin development)

```yaml
dependencies:
  zebra_datawedge:
    path: ../zebra_datawedge
```

## First Working Integration (Step-by-Step)

This is the simplest production-style setup.

### Step 1: Import and create one shared service

```dart
import 'dart:async';

import 'package:zebra_datawedge/zebra_datawedge.dart';

class ZebraScannerService {
  ZebraScannerService({required this.androidPackageName});

  final String androidPackageName;
  final ZebraDataWedge _dataWedge = ZebraDataWedge();

  StreamSubscription<DataWedgeEvent>? _subscription;

  String? lastBarcode;
  String? lastLabelType;
  String? lastCommandResult;

  Future<void> initialize() async {
    final bool available = await _dataWedge.isAvailable();
    if (!available) {
      throw StateError(
        'DataWedge is not available on this device. Use a Zebra device with DataWedge installed.',
      );
    }

    await _dataWedge.configureClassicBarcodeProfile(
      profileName: 'MY_APP_PROFILE',
      packageName: androidPackageName,
    );

    await _dataWedge.switchToProfile('MY_APP_PROFILE');
    await _dataWedge.registerForDefaultNotifications();

    _subscription = _dataWedge.events.listen(_onEvent);
  }

  void _onEvent(DataWedgeEvent event) {
    if (event.isScan) {
      lastBarcode = event.scanData;
      lastLabelType = event.labelType;
      return;
    }

    if (event.isCommandResult) {
      final String command = event.command ?? 'UNKNOWN_COMMAND';
      final String result = event.result ?? 'UNKNOWN_RESULT';
      lastCommandResult = '$command -> $result';
      return;
    }

    if (event.isNotification) {
      final String notificationType = event.notificationType ?? 'UNKNOWN_NOTIFICATION';
      final String status = event.scannerStatus ?? 'UNKNOWN_STATUS';
      lastCommandResult = 'Notification: $notificationType -> $status';
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
  }
}
```

Why this code is structured this way:

1. `androidPackageName` must match your Android app package (applicationId). It is used to bind the DataWedge profile to your app.
2. `ZebraDataWedge _dataWedge` is one shared API instance for all scanner operations.
3. `initialize()` starts with `isAvailable()` so you fail fast on unsupported devices.
4. `configureClassicBarcodeProfile(...)` creates a practical default profile for most barcode apps.
5. `switchToProfile(...)` ensures the active profile is the one your app expects.
6. `registerForDefaultNotifications()` helps you observe scanner/profile state.
7. `_dataWedge.events.listen(_onEvent)` is the main event bridge from Android to Flutter.
8. `dispose()` cancels the stream subscription to prevent memory leaks.

### Step 2: Use it from your UI

```dart
late final ZebraScannerService scannerService;

@override
void initState() {
  super.initState();
  scannerService = ZebraScannerService(
    androidPackageName: 'com.example.my_app',
  );

  scannerService.initialize();
}

@override
void dispose() {
  scannerService.dispose();
  super.dispose();
}
```

How to set the package name correctly:

- Open `android/app/build.gradle` in your app.
- Find `defaultConfig` and read `applicationId`.
- Use that exact value in `androidPackageName` and profile app association.

### Step 3: Test the flow

1. Open the app on a Zebra device.
2. Trigger scanner (hardware button or soft scan API).
3. Confirm scan events arrive.
4. Confirm command results show success.

## Understanding Events and Payloads

This package exposes 2 streams:

- `scanStream`: raw `Map<String, dynamic>`
- `events`: typed `DataWedgeEvent`

Most apps should use `events`.

### Event types

1. `scan`
   Typical keys:
   - `data`: scanned text
   - `labelType`: barcode type
   - `extras`: full intent extras map

2. `commandResult`
   Typical keys:
   - `command`
   - `result` (usually `SUCCESS` or `FAILURE`)
   - `commandId`
   - `resultInfo`
   - `resultInfoText`

3. `notification`
   Typical keys:
   - `notificationType`
   - `status`
   - `profileName`
   - `raw`

4. `debug`
   Typical keys:
   - `message`

### Recommended event handling strategy

- Handle `scan` in your business logic.
- Log `commandResult` for diagnostics and reliability.
- Use `notification` to react to scanner/profile state changes.

## Profile Setup in Depth

This package gives you 2 profile approaches.

### A) Fast setup with `configureClassicBarcodeProfile`

Use this when you want a reliable default profile quickly.
It configures:

- BARCODE plugin enabled
- INTENT output enabled (broadcast)
- KEYSTROKE output disabled
- App association set to your package

```dart
await ZebraDataWedge().configureClassicBarcodeProfile(
  profileName: 'MY_APP_PROFILE',
  packageName: 'com.example.my_app',
);
```

Parameter explanation:

1. `profileName`: the DataWedge profile to create or update.
2. `packageName`: your Android app id that receives scan intents.
3. Optional arguments (not shown) let you customize intent action, delivery mode, activities, and notification behavior.

### B) Advanced setup with `DataWedgeProfileBuilder`

Use this for large apps with multiple scanner modes.

```dart
final DataWedgeProfileConfiguration profile = DataWedgeProfileBuilder(
  profileName: 'WAREHOUSE_PROFILE',
  configMode: DataWedgeConfigMode.createIfNotExist,
)
    .setProfileEnabled(true)
    .addPlugin(
      DataWedgePluginConfiguration(
        pluginName: DataWedgePluginName.barcode,
        resetConfig: true,
        paramList: <String, dynamic>{
          'scanner_selection': 'auto',
          'scanner_selection_by_identifier': DataWedgeScannerIdentifier.auto,
          'scanner_input_enabled': 'true',
        },
      ),
    )
    .addPlugin(
      DataWedgePluginConfiguration(
        pluginName: DataWedgePluginName.intent,
        resetConfig: true,
        paramList: <String, dynamic>{
          'intent_output_enabled': 'true',
          'intent_action': 'com.example.my_app.SCAN',
          'intent_category': DataWedgeApi.defaultIntentCategory,
          'intent_delivery': DataWedgeIntentDelivery.broadcast,
        },
      ),
    )
    .addAppAssociation(
      const DataWedgeAppAssociation(
        packageName: 'com.example.my_app',
        activityList: <String>[DataWedgeApi.wildcard],
      ),
    )
    .build();

await ZebraDataWedge().setConfig(profile);
```

Builder chain explanation:

1. `DataWedgeProfileBuilder(...)` creates a mutable builder object.
2. `.setProfileEnabled(true)` ensures profile is active.
3. First `.addPlugin(...)` enables BARCODE input settings.
4. Second `.addPlugin(...)` enables INTENT output settings.
5. `.addAppAssociation(...)` binds profile to app package and activities.
6. `.build()` converts builder state into immutable `DataWedgeProfileConfiguration`.
7. `setConfig(profile)` sends final config bundle to DataWedge.

## API Guide by Use Case

### 1) Availability and setup

- `isAvailable`
- `configureProfile`
- `configureClassicBarcodeProfile`
- `switchToProfile`

### 2) Profile management

- `createProfile`
- `cloneProfile`
- `renameProfile`
- `deleteProfiles`
- `deleteAllDeletableProfiles`
- `setConfig`
- `applyProfileConfiguration`
- `getConfig`
- `setDefaultProfile`
- `resetDefaultProfile`

### 3) Notifications

- `registerForNotification`
- `unregisterForNotification`
- `registerForDefaultNotifications`

Notification constants:

- `DataWedgeNotificationType.scannerStatus`
- `DataWedgeNotificationType.profileSwitch`
- `DataWedgeNotificationType.configurationUpdate`
- `DataWedgeNotificationType.workflowStatus`

### 4) Queries and diagnostics

- `getActiveProfile`
- `getProfilesList`
- `getVersionInfo`
- `getDataWedgeStatus`
- `getScannerStatus`
- `enumerateScanners`
- `enumerateTriggers`
- `enumerateWorkflows`
- `getDisabledAppList`
- `getIgnoreDisabledProfiles`

### 5) Runtime scanner control

- `startSoftScan`
- `stopSoftScan`
- `toggleSoftScan`
- `softScanTrigger`
- `enableScanner`
- `disableScanner`
- `suspendScanner`
- `resumeScanner`
- `softRfidTrigger`
- `softVoiceTrigger`
- `switchScannerByIndex`
- `switchScannerByIdentifier`
- `switchScannerParams`
- `switchDataCapture`
- `setDataWedgeEnabled`

### 6) Import/export and app control

- `importConfig`
- `exportConfig`
- `setDisabledAppList`
- `setIgnoreDisabledProfiles`

### 7) Scale and Bluetooth notification APIs

- `getWeight`
- `setScaleToZero`
- `notifyBluetoothScanner`
- `customNotifyBluetoothScanner`

### 8) Generic future-proof APIs

- `sendCommand`
- `sendCommandBundle`
- `sendIntent`

Use these when Zebra introduces a new command that is not yet wrapped by a typed helper.

## Reliable Command Handling Pattern

When sending commands, always think in request/response style:

1. Send command with a unique `commandTag`.
2. Keep `requestResult: true`.
3. Listen for `commandResult` events.
4. Match by `commandId` or command name.
5. Handle failures with retry or fallback.

Example:

```dart
await ZebraDataWedge().sendCommand(
  command: DataWedgeApi.getVersionInfo,
  value: '',
  commandTag: 'GET_VERSION_FOR_STARTUP_CHECK',
  requestResult: true,
);
```

What each argument means:

1. `command`: which DataWedge API command you are sending.
2. `value`: command payload; query commands usually use an empty string.
3. `commandTag`: your custom tracking id prefix for logs and correlation.
4. `requestResult`: when true, DataWedge returns a `commandResult` event.

## Advanced Examples

### Soft scan for a specific scanner

```dart
await ZebraDataWedge().softScanTrigger(
  action: DataWedgeSoftScanAction.toggle,
  scannerSelectionByIdentifier: DataWedgeScannerIdentifier.bluetoothRs6000,
);
```

### Switch scanner parameters at runtime

```dart
await ZebraDataWedge().switchScannerParams(
  scannerSelectionByIdentifier: DataWedgeScannerIdentifier.internalImager,
  parameters: <String, dynamic>{
    'illumination_mode': 'off',
  },
);
```

### Switch data capture to workflow mode

```dart
await ZebraDataWedge().switchDataCapture(
  targetPlugin: DataWedgeSwitchDataCaptureTarget.workflow,
  paramList: <String, dynamic>{
    'workflow_name': DataWedgeWorkflowName.idScanning,
    'workflow_input_source': DataWedgeWorkflowInputSource.camera,
  },
);
```

### Import and export DataWedge config

```dart
await ZebraDataWedge().exportConfig(
  const DataWedgeExportConfigRequest(
    folderPath: '/storage/emulated/0/Download/',
    exportType: DataWedgeExportType.profileConfig,
    profileName: 'MY_APP_PROFILE',
  ),
);

await ZebraDataWedge().importConfig(
  const DataWedgeImportConfigRequest(
    folderPath: '/sdcard/configFolder',
    fileList: <String>['dwprofile_MY_APP_PROFILE.db'],
  ),
);
```

## Troubleshooting Guide

### Problem: No scan data arrives

Checklist:

1. Confirm device is Zebra and DataWedge is installed.
2. Confirm `isAvailable()` returns true.
3. Confirm profile is associated with your app package.
4. Confirm INTENT output is enabled.
5. Confirm your app is using the same package name used in profile config.

### Problem: Commands seem ignored

Checklist:

1. Keep `requestResult: true` and inspect `commandResult` events.
2. Check DataWedge status using `getDataWedgeStatus`.
3. Ensure profile exists before switching to it.
4. Validate command parameters against Zebra docs.

### Problem: Works on one device, fails on another

Checklist:

1. Compare DataWedge versions using `getVersionInfo`.
2. Compare available scanners with `enumerateScanners`.
3. Compare supported workflows using `enumerateWorkflows`.

## License

This package is distributed under the MIT License.
See [LICENSE](LICENSE) for full terms.

## Legal and Trademark Notice

- This is an independent open-source project and is not affiliated with or endorsed by Zebra Technologies.
- This package works with Zebra devices and DataWedge APIs; it is not an official Zebra plugin.
- Zebra, DataWedge, and related marks are trademarks of Zebra Technologies Corporation and/or its affiliates.
- This plugin is designed to use public DataWedge APIs exposed on compatible Zebra Android devices.
- You are responsible for following Zebra device software terms, API documentation terms, and any trademark usage rules in your product, docs, or store listing.

## References

- DataWedge Overview: https://techdocs.zebra.com/datawedge/latest/guide/about/
- DataWedge API Reference: https://techdocs.zebra.com/datawedge/latest/guide/api/
- DataWedge Profiles: https://techdocs.zebra.com/datawedge/latest/guide/profiles/
- Feature Matrix: https://techdocs.zebra.com/datawedge/latest/guide/matrix/
