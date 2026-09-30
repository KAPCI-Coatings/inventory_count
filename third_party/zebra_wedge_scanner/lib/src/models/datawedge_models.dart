/// Constants for Zebra DataWedge API commands and parameters.
///
/// This class contains all the constant strings used to interact with
/// the Zebra DataWedge service via Android intents.
class DataWedgeApi {
  const DataWedgeApi._();

  /// The main DataWedge API action for sending commands.
  static const String action = 'com.symbol.datawedge.api.ACTION';

  /// The result action for receiving command results.
  static const String resultAction = 'com.symbol.datawedge.api.RESULT_ACTION';

  /// The notification action for receiving DataWedge notifications.
  static const String notificationAction =
      'com.symbol.datawedge.api.NOTIFICATION_ACTION';

  /// The Zebra DataWedge package name.
  static const String dataWedgePackage = 'com.symbol.datawedge';

  /// Key for requesting result delivery in commands.
  static const String sendResultKey = 'SEND_RESULT';

  /// Value for receiving only the last result.
  static const String sendResultLast = 'LAST_RESULT';

  /// Value for receiving complete results.
  static const String sendResultComplete = 'COMPLETE_RESULT';

  /// Key for identifying commands in result callbacks.
  static const String commandIdentifierKey = 'COMMAND_IDENTIFIER';

  /// Key for the command parameter in intents.
  static const String commandKey = 'COMMAND';

  /// Key for the result value in responses.
  static const String resultKey = 'RESULT';

  /// Key for additional result info in responses.
  static const String resultInfoKey = 'RESULT_INFO';

  /// Key for the application name in intents.
  static const String applicationNameKey = 'APPLICATION_NAME';

  /// Key for the application package in intents.
  static const String applicationPackageKey = 'APPLICATION_PACKAGE';

  /// Command to create a new DataWedge profile.
  static const String createProfile = 'com.symbol.datawedge.api.CREATE_PROFILE';

  /// Command to clone an existing profile.
  static const String cloneProfile = 'com.symbol.datawedge.api.CLONE_PROFILE';

  /// Command to delete one or more profiles.
  static const String deleteProfile = 'com.symbol.datawedge.api.DELETE_PROFILE';

  /// Command to rename an existing profile.
  static const String renameProfile = 'com.symbol.datawedge.api.RENAME_PROFILE';

  /// Command to set (apply) a profile configuration.
  static const String setConfig = 'com.symbol.datawedge.api.SET_CONFIG';

  /// Command to get the configuration of a profile.
  static const String getConfig = 'com.symbol.datawedge.api.GET_CONFIG';

  /// Command to import DataWedge configuration from files.
  static const String importConfig = 'com.symbol.datawedge.api.IMPORT_CONFIG';

  /// Command to export DataWedge configuration to files.
  static const String exportConfig = 'com.symbol.datawedge.api.EXPORT_CONFIG';

  /// Command to set the list of apps where DataWedge is disabled.
  static const String setDisabledAppList =
      'com.symbol.datawedge.api.SET_DISABLED_APP_LIST';

  /// Command to get the list of apps where DataWedge is disabled.
  static const String getDisabledAppList =
      'com.symbol.datawedge.api.GET_DISABLED_APP_LIST';

  /// Command to set whether to ignore disabled profiles.
  static const String setIgnoreDisabledProfiles =
      'com.symbol.datawedge.api.SET_IGNORE_DISABLED_PROFILES';

  /// Command to get whether disabled profiles are ignored.
  static const String getIgnoreDisabledProfiles =
      'com.symbol.datawedge.api.GET_IGNORE_DISABLED_PROFILES';

  /// Command to register for DataWedge notifications.
  static const String registerForNotification =
      'com.symbol.datawedge.api.REGISTER_FOR_NOTIFICATION';

  /// Command to unregister from DataWedge notifications.
  static const String unregisterForNotification =
      'com.symbol.datawedge.api.UNREGISTER_FOR_NOTIFICATION';

  /// Key for the notification bundle in broadcast intents.
  static const String notificationBundle = 'com.symbol.datawedge.api.NOTIFICATION';

  /// Command to enumerate all available scanners.
  static const String enumerateScanners =
      'com.symbol.datawedge.api.ENUMERATE_SCANNERS';

  /// Command to get the currently active profile.
  static const String getActiveProfile =
      'com.symbol.datawedge.api.GET_ACTIVE_PROFILE';

  /// Command to get the list of all profiles.
  static const String getProfilesList =
      'com.symbol.datawedge.api.GET_PROFILES_LIST';

  /// Command to get the DataWedge version info.
  static const String getVersionInfo =
      'com.symbol.datawedge.api.GET_VERSION_INFO';

  /// Command to get the DataWedge service status.
  static const String getDataWedgeStatus =
      'com.symbol.datawedge.api.GET_DATAWEDGE_STATUS';

  /// Command to get the current scanner status.
  static const String getScannerStatus =
      'com.symbol.datawedge.api.GET_SCANNER_STATUS';

  /// Command to enumerate all trigger sources.
  static const String enumerateTriggers =
      'com.symbol.datawedge.api.ENUMERATE_TRIGGERS';

  /// Command to enumerate all workflows.
  static const String enumerateWorkflows =
      'com.symbol.datawedge.api.ENUMERATE_WORKFLOWS';

  /// Command to enable or disable the DataWedge service.
  static const String enableDataWedge =
      'com.symbol.datawedge.api.ENABLE_DATAWEDGE';

  /// Command to control the scanner input plugin (enable, disable, suspend, resume).
  static const String scannerInputPlugin =
      'com.symbol.datawedge.api.SCANNER_INPUT_PLUGIN';

  /// Command to trigger a software scan (start, stop, toggle).
  static const String softScanTrigger =
      'com.symbol.datawedge.api.SOFT_SCAN_TRIGGER';

  /// Command to trigger a software RFID scan.
  static const String softRfidTrigger =
      'com.symbol.datawedge.api.SOFT_RFID_TRIGGER';

  /// Key for soft trigger actions in intents.
  static const String softTrigger = 'com.symbol.datawedge.api.SOFT_TRIGGER';

  /// Command to switch to a specific profile.
  static const String switchToProfile =
      'com.symbol.datawedge.api.SWITCH_TO_PROFILE';

  /// Command to set the default profile.
  static const String setDefaultProfile =
      'com.symbol.datawedge.api.SET_DEFAULT_PROFILE';

  /// Command to reset the default profile.
  static const String resetDefaultProfile =
      'com.symbol.datawedge.api.RESET_DEFAULT_PROFILE';

  /// Command to switch scanner by index.
  static const String switchScanner = 'com.symbol.datawedge.api.SWITCH_SCANNER';

  /// Command to switch scanner by identifier.
  static const String switchScannerEx =
      'com.symbol.datawedge.api.SWITCH_SCANNER_EX';

  /// Command to update scanner parameters.
  static const String switchScannerParams =
      'com.symbol.datawedge.api.SWITCH_SCANNER_PARAMS';

  /// Command to switch the active data capture plugin.
  static const String switchDataCapture =
      'com.symbol.datawedge.api.SWITCH_DATACAPTURE';

  /// Command to interact with a connected scale (get weight, tare).
  static const String scale = 'com.symbol.datawedge.api.SCALE';

  /// Command to send notifications to Bluetooth scanners.
  static const String notify = 'com.symbol.datawedge.api.notification.NOTIFY';

  /// Result key for getConfig command.
  static const String resultGetConfig = 'com.symbol.datawedge.api.RESULT_GET_CONFIG';

  /// Result key for getActiveProfile command.
  static const String resultGetActiveProfile =
      'com.symbol.datawedge.api.RESULT_GET_ACTIVE_PROFILE';

  /// Result key for getProfilesList command.
  static const String resultGetProfilesList =
      'com.symbol.datawedge.api.RESULT_GET_PROFILES_LIST';

  /// Result key for getVersionInfo command.
  static const String resultGetVersionInfo =
      'com.symbol.datawedge.api.RESULT_GET_VERSION_INFO';

  /// Result key for getDataWedgeStatus command.
  static const String resultGetDataWedgeStatus =
      'com.symbol.datawedge.api.RESULT_GET_DATAWEDGE_STATUS';

  /// Result key for getScannerStatus command.
  static const String resultGetScannerStatus =
      'com.symbol.datawedge.api.RESULT_SCANNER_STATUS';

  /// Result key for getDisabledAppList command.
  static const String resultGetDisabledAppList =
      'com.symbol.datawedge.api.RESULT_GET_DISABLED_APP_LIST';

  /// Result key for enumerateScanners command.
  static const String resultEnumerateScanners =
      'com.symbol.datawedge.api.RESULT_ENUMERATE_SCANNERS';

  /// Result key for enumerateTriggers command.
  static const String resultEnumerateTriggers =
      'com.symbol.datawedge.api.RESULT_ENUMERATE_TRIGGERS';

  /// Result key for enumerateWorkflows command.
  static const String resultEnumerateWorkflows =
      'com.symbol.datawedge.api.RESULT_ENUMERATE_WORKFLOWS';

  /// Key for the profile name parameter.
  static const String profileNameKey = 'PROFILE_NAME';

  /// Key for the profile enabled parameter.
  static const String profileEnabledKey = 'PROFILE_ENABLED';

  /// Key for the config mode parameter.
  static const String configModeKey = 'CONFIG_MODE';

  /// Key for the reset config parameter.
  static const String resetConfigKey = 'RESET_CONFIG';

  /// Key for the app list parameter in profile configuration.
  static const String appListKey = 'APP_LIST';

  /// Key for the plugin configuration parameter.
  static const String pluginConfigKey = 'PLUGIN_CONFIG';

  /// Key for the plugin name parameter.
  static const String pluginNameKey = 'PLUGIN_NAME';

  /// Key for the output plugin name parameter.
  static const String outputPluginNameKey = 'OUTPUT_PLUGIN_NAME';

  /// Key for the process plugin name parameter.
  static const String processPluginNameKey = 'PROCESS_PLUGIN_NAME';

  /// Key for the parameter list in plugin configuration.
  static const String paramListKey = 'PARAM_LIST';

  /// Key for the package name parameter.
  static const String packageNameKey = 'PACKAGE_NAME';

  /// Key for the activity list parameter.
  static const String activityListKey = 'ACTIVITY_LIST';

  /// Wildcard value for matching all items.
  static const String wildcard = '*';

  /// Key for selecting a scanner by identifier.
  static const String scannerSelectionByIdentifier =
      'scanner_selection_by_identifier';

  /// Key for selecting a scanner (by type name).
  static const String scannerSelection = 'scanner_selection';

  /// Default intent category for DataWedge intents.
  static const String defaultIntentCategory = 'android.intent.category.DEFAULT';
}

/// Configuration modes for creating or updating DataWedge profiles.
class DataWedgeConfigMode {
  const DataWedgeConfigMode._();

  /// Create the profile only if it doesn't already exist.
  static const String createIfNotExist = 'CREATE_IF_NOT_EXIST';

  /// Overwrite the existing profile configuration completely.
  static const String overwrite = 'OVERWRITE';

  /// Update the existing profile with new settings (merge).
  static const String update = 'UPDATE';
}

/// Modes for updating the disabled app list.
class DataWedgeDisabledAppListMode {
  const DataWedgeDisabledAppListMode._();

  /// Add apps to the existing disabled list.
  static const String update = 'UPDATE';

  /// Remove apps from the disabled list.
  static const String remove = 'REMOVE';

  /// Replace the entire disabled list with the new one.
  static const String overwrite = 'OVERWRITE';
}

/// Export types for DataWedge configuration export.
class DataWedgeExportType {
  const DataWedgeExportType._();

  /// Export only profile configurations.
  static const String profileConfig = 'PROFILE_CONFIG';

  /// Export the full DataWedge configuration.
  static const String fullConfig = 'FULL_CONFIG';
}

/// Notification types for DataWedge events.
///
/// Register for these notifications using [ZebraDataWedge.registerForNotification].
class DataWedgeNotificationType {
  const DataWedgeNotificationType._();

  /// Notifications for scanner state changes (enabled, disabled, waiting, etc.).
  static const String scannerStatus = 'SCANNER_STATUS';

  /// Notifications when the active profile is switched.
  static const String profileSwitch = 'PROFILE_SWITCH';

  /// Notifications when the DataWedge configuration is updated.
  static const String configurationUpdate = 'CONFIGURATION_UPDATE';

  /// Notifications for workflow state changes.
  static const String workflowStatus = 'WORKFLOW_STATUS';
}

/// Plugin names for DataWedge configuration.
///
/// Use these constants when configuring plugins in a profile.
class DataWedgePluginName {
  const DataWedgePluginName._();

  /// Barcode scanning plugin.
  static const String barcode = 'BARCODE';

  /// Magnetic stripe reader plugin.
  static const String msr = 'MSR';

  /// RFID plugin.
  static const String rfid = 'RFID';

  /// Serial input plugin.
  static const String serial = 'SERIAL';

  /// Voice input plugin.
  static const String voice = 'VOICE';

  /// Workflow plugin for advanced data capture.
  static const String workflow = 'WORKFLOW';

  /// Basic Data Formatting plugin.
  static const String bdf = 'BDF';

  /// Advanced Data Formatting plugin.
  static const String adf = 'ADF';

  /// Token plugin.
  static const String token = 'TOKEN';

  /// Intent output plugin.
  static const String intent = 'INTENT';

  /// Keystroke output plugin.
  static const String keystroke = 'KEYSTROKE';

  /// IP output plugin.
  static const String ip = 'IP';

  /// DataCapture Plus plugin.
  static const String dcp = 'DCP';

  /// Enterprise Keyboard plugin.
  static const String ekb = 'EKB';
}

/// Intent delivery methods for the intent output plugin.
class DataWedgeIntentDelivery {
  const DataWedgeIntentDelivery._();

  /// Deliver intent via startActivity.
  static const int startActivity = 0;

  /// Deliver intent via startService.
  static const int startService = 1;

  /// Deliver intent via broadcast (most common).
  static const int broadcast = 2;

  /// Deliver intent via startForegroundService.
  static const int startForegroundService = 3;
}

/// Actions for controlling the scanner input plugin.
class DataWedgeScannerInputAction {
  const DataWedgeScannerInputAction._();

  /// Enables the scanner plugin.
  static const String enablePlugin = 'ENABLE_PLUGIN';

  /// Disables the scanner plugin.
  static const String disablePlugin = 'DISABLE_PLUGIN';

  /// Suspends the scanner plugin (temporary disable).
  static const String suspendPlugin = 'SUSPEND_PLUGIN';

  /// Resumes a suspended scanner plugin.
  static const String resumePlugin = 'RESUME_PLUGIN';
}

/// Actions for software scan trigger control.
class DataWedgeSoftScanAction {
  const DataWedgeSoftScanAction._();

  /// Starts scanning.
  static const String start = 'START_SCANNING';

  /// Stops scanning.
  static const String stop = 'STOP_SCANNING';

  /// Toggles between start and stop.
  static const String toggle = 'TOGGLE_SCANNING';
}

/// Actions for generic soft trigger control (RFID, Voice, etc.).
class DataWedgeSoftTriggerAction {
  const DataWedgeSoftTriggerAction._();

  /// Starts the trigger action.
  static const String start = 'START';

  /// Stops the trigger action.
  static const String stop = 'STOP';

  /// Toggles the trigger action.
  static const String toggle = 'TOGGLE';
}

/// Target plugins for the switch data capture command.
class DataWedgeSwitchDataCaptureTarget {
  const DataWedgeSwitchDataCaptureTarget._();

  /// Switch to barcode capture.
  static const String barcode = 'BARCODE';

  /// Switch to workflow capture.
  static const String workflow = 'WORKFLOW';
}

/// Predefined workflow names for Zebra DataWedge.
class DataWedgeWorkflowName {
  const DataWedgeWorkflowName._();

  /// License plate recognition workflow.
  static const String licensePlate = 'license_plate';

  /// ID document scanning workflow.
  static const String idScanning = 'id_scanning';

  /// VIN (Vehicle Identification Number) scanning workflow.
  static const String vinNumber = 'vin_number';

  /// TIN (Tax Identification Number) scanning workflow.
  static const String tinNumber = 'tin_number';

  /// Container scanning workflow.
  static const String containerScanning = 'container_scanning';

  /// Meter reading workflow.
  static const String meterReading = 'meter_reading';

  /// Free-form text capture workflow.
  static const String freeFormCapture = 'free_form_capture';

  /// Document capture workflow.
  static const String documentCapture = 'document_capture';

  /// Picklist OCR workflow.
  static const String picklistOcr = 'picklist_ocr';

  /// Free-form OCR workflow.
  static const String freeFormOcr = 'free_form_ocr';

  /// Basic multi-barcode scanning workflow.
  static const String basicMultibarcode = 'basic_multibarcode';
}

/// Input sources for workflow configurations.
class DataWedgeWorkflowInputSource {
  const DataWedgeWorkflowInputSource._();

  /// Use the device imager (camera/scanner).
  static const String imager = '1';

  /// Use the device camera.
  static const String camera = '2';
}

/// Commands for scale (weight) operations.
class DataWedgeScaleCommand {
  const DataWedgeScaleCommand._();

  /// Get the current weight from the scale.
  static const String getWeight = 'GET_WEIGHT';

  /// Set the scale to zero (tare).
  static const String setScaleToZero = 'SET_SCALE_TO_ZERO';
}

/// Scanner identifier constants for selecting specific scanners.
///
/// Use these constants with [ZebraDataWedge.switchScannerByIdentifier]
/// and other scanner selection commands.
class DataWedgeScannerIdentifier {
  const DataWedgeScannerIdentifier._();

  /// Automatic scanner selection (let DataWedge choose).
  static const String auto = 'AUTO';

  /// Internal imager scanner.
  static const String internalImager = 'INTERNAL_IMAGER';

  /// Internal laser scanner.
  static const String internalLaser = 'INTERNAL_LASER';

  /// Internal camera scanner.
  static const String internalCamera = 'INTERNAL_CAMERA';

  /// Serial SSI connection.
  static const String serialSsi = 'SERIAL_SSI';

  /// Bluetooth SSI connection.
  static const String bluetoothSsi = 'BLUETOOTH_SSI';

  /// Bluetooth RS5100 scanner.
  static const String bluetoothRs5100 = 'BLUETOOTH_RS5100';

  /// Bluetooth RS6000 scanner.
  static const String bluetoothRs6000 = 'BLUETOOTH_RS6000';

  /// Bluetooth DS2278 scanner.
  static const String bluetoothDs2278 = 'BLUETOOTH_DS2278';

  /// Bluetooth DS3678 scanner.
  static const String bluetoothDs3678 = 'BLUETOOTH_DS3678';

  /// Bluetooth DS8178 scanner.
  static const String bluetoothDs8178 = 'BLUETOOTH_DS8178';

  /// Bluetooth LI3678 scanner.
  static const String bluetoothLi3678 = 'BLUETOOTH_LI3678';

  /// Generic Zebra Bluetooth scanner.
  static const String bluetoothZebra = 'BLUETOOTH_ZEBRA';

  /// Generic Bluetooth scanner.
  static const String bluetoothGeneric = 'BLUETOOTH_GENERIC';

  /// Plugable SSI connection.
  static const String plugableSsi = 'PLUGABLE_SSI';

  /// Plugable SSI RS5000 scanner.
  static const String plugableSsiRs5000 = 'PLUGABLE_SSI_RS5000';

  /// USB SSI DS3608 scanner.
  static const String usbSsiDs3608 = 'USB_SSI_DS3608';

  /// USB TGCS MP7000 scale.
  static const String usbTgcsMp7000 = 'USB_TGCS_MP7000';

  /// Generic USB Zebra scanner.
  static const String usbZebra = 'USB_ZEBRA';
}

/// Event types emitted by the DataWedge service.
class DataWedgeEventType {
  const DataWedgeEventType._();

  /// A barcode or RFID scan event.
  static const String scan = 'scan';

  /// Result of a command sent to DataWedge.
  static const String commandResult = 'commandResult';

  /// A notification event (scanner status, profile switch, etc.).
  static const String notification = 'notification';

  /// Debug event from DataWedge.
  static const String debug = 'debug';

  /// Unknown or unrecognized event type.
  static const String unknown = 'unknown';
}

/// Converts a boolean value to the string format expected by DataWedge.
///
/// DataWedge expects 'true' or 'false' (lowercase strings) for boolean parameters.
String dataWedgeBool(bool value) {
  return value ? 'true' : 'false';
}

/// Represents a DataWedge event received from the service.
///
/// Events can be scan results, command results, or notifications.
/// Use the type getters ([isScan], [isCommandResult], [isNotification])
/// to determine the event type and access the appropriate fields.
class DataWedgeEvent {
  /// Creates a new [DataWedgeEvent].
  DataWedgeEvent({required this.type, required this.payload});

  /// Creates a [DataWedgeEvent] from a raw event map.
  factory DataWedgeEvent.fromMap(Map<String, dynamic> rawEvent) {
    final Map<String, dynamic> payload = Map<String, dynamic>.from(rawEvent);
    final String type = (payload['type'] as String?) ?? DataWedgeEventType.unknown;
    return DataWedgeEvent(type: type, payload: payload);
  }

  /// The type of the event (scan, commandResult, notification, debug, unknown).
  final String type;

  /// The raw payload of the event.
  final Map<String, dynamic> payload;

  /// Returns true if this is a scan event.
  bool get isScan => type == DataWedgeEventType.scan;

  /// Returns true if this is a command result event.
  bool get isCommandResult => type == DataWedgeEventType.commandResult;

  /// Returns true if this is a notification event.
  bool get isNotification => type == DataWedgeEventType.notification;

  /// The scanned data (for scan events).
  String? get scanData => payload['data'] as String?;

  /// The label type of the scanned barcode (for scan events).
  String? get labelType => payload['labelType'] as String?;

  /// The notification type (for notification events).
  String? get notificationType => payload['notificationType'] as String?;

  /// The scanner status (for scanner status notifications).
  String? get scannerStatus => payload['status'] as String?;

  /// The command that was executed (for command result events).
  String? get command => payload['command'] as String?;

  /// The command identifier for correlating commands with results.
  String? get commandIdentifier =>
      payload['commandId'] as String? ?? payload[DataWedgeApi.commandIdentifierKey] as String?;

  /// The result of the command (for command result events).
  String? get result => payload['result'] as String?;
}

/// Defines an app association for a DataWedge profile.
///
/// This specifies which app (and optionally which activities) the profile applies to.
class DataWedgeAppAssociation {
  /// Creates a new app association.
  ///
  /// [packageName] is the Android package name of the app.
  /// [activityList] specifies which activities the profile applies to
  /// (defaults to ['*'] for all activities).
  const DataWedgeAppAssociation({
    required this.packageName,
    this.activityList = const <String>[DataWedgeApi.wildcard],
  });

  /// The Android package name of the associated app.
  final String packageName;

  /// List of activities the profile applies to.
  final List<String> activityList;

  /// Converts this association to a Map for DataWedge.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      DataWedgeApi.packageNameKey: packageName,
      DataWedgeApi.activityListKey: activityList,
    };
  }
}

/// Configuration for a DataWedge plugin.
///
/// Use this to configure plugins like barcode, intent, keystroke, etc.
class DataWedgePluginConfiguration {
  /// Creates a new plugin configuration.
  ///
  /// [pluginName] is the name of the plugin (use [DataWedgePluginName] constants).
  /// [resetConfig] when true, resets the plugin config before applying new settings.
  /// [paramList] is the plugin-specific parameters.
  /// [outputPluginName] is the associated output plugin (for process plugins).
  /// [extra] is additional parameters to include in the configuration.
  const DataWedgePluginConfiguration({
    required this.pluginName,
    this.resetConfig = true,
    this.paramList,
    this.outputPluginName,
    this.extra = const <String, dynamic>{},
  });

  /// The name of the plugin to configure.
  final String pluginName;

  /// Whether to reset the plugin configuration before applying.
  final bool resetConfig;

  /// Plugin-specific parameters.
  final Object? paramList;

  /// The associated output plugin name (for process plugins).
  final String? outputPluginName;

  /// Additional parameters to include.
  final Map<String, dynamic> extra;

  /// Converts this configuration to a Map for DataWedge.
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = <String, dynamic>{
      DataWedgeApi.pluginNameKey: pluginName,
      DataWedgeApi.resetConfigKey: dataWedgeBool(resetConfig),
    };

    if (outputPluginName != null) {
      map[DataWedgeApi.outputPluginNameKey] = outputPluginName;
    }
    if (paramList != null) {
      map[DataWedgeApi.paramListKey] = paramList;
    }
    map.addAll(extra);

    return map;
  }
}

/// Request to process a plugin in a getConfig command.
class DataWedgeProcessPluginRequest {
  /// Creates a new process plugin request.
  const DataWedgeProcessPluginRequest({
    required this.pluginName,
    this.outputPluginName,
  });

  /// The name of the plugin to process.
  final String pluginName;

  /// The associated output plugin name.
  final String? outputPluginName;

  /// Converts this request to a Map for DataWedge.
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = <String, dynamic>{
      DataWedgeApi.pluginNameKey: pluginName,
    };
    if (outputPluginName != null) {
      map[DataWedgeApi.outputPluginNameKey] = outputPluginName;
    }
    return map;
  }
}

/// A module configuration for workflow plugins.
class DataWedgeWorkflowModule {
  /// Creates a new workflow module configuration.
  const DataWedgeWorkflowModule({
    required this.module,
    required this.moduleParams,
  });

  /// The module name.
  final String module;

  /// Parameters for the module.
  final Map<String, dynamic> moduleParams;

  /// Converts this module to a Map for DataWedge.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'module': module,
      'module_params': moduleParams,
    };
  }
}

/// Configuration for a DataWedge workflow.
class DataWedgeWorkflowConfiguration {
  /// Creates a new workflow configuration.
  ///
  /// [workflowName] is the name of the workflow (use [DataWedgeWorkflowName] constants).
  /// [workflowInputSource] is the input source (use [DataWedgeWorkflowInputSource] constants).
  /// [modules] are the workflow modules to configure.
  const DataWedgeWorkflowConfiguration({
    required this.workflowName,
    this.workflowInputSource = DataWedgeWorkflowInputSource.imager,
    this.modules = const <DataWedgeWorkflowModule>[],
  });

  /// The name of the workflow.
  final String workflowName;

  /// The input source for the workflow.
  final String workflowInputSource;

  /// Modules configured for this workflow.
  final List<DataWedgeWorkflowModule> modules;

  /// Converts this configuration to a Map for DataWedge.
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = <String, dynamic>{
      'workflow_name': workflowName,
      'workflow_input_source': workflowInputSource,
    };

    if (modules.isNotEmpty) {
      map['workflow_params'] =
          modules.map<Map<String, dynamic>>((DataWedgeWorkflowModule m) {
        return m.toMap();
      }).toList();
    }

    return map;
  }
}

/// Complete configuration for a DataWedge profile.
///
/// This class encapsulates all settings for a DataWedge profile including
/// plugin configurations, app associations, and optional features.
class DataWedgeProfileConfiguration {
  /// Creates a new profile configuration.
  ///
  /// [profileName] is the name of the profile.
  /// [configMode] determines how the config is applied (see [DataWedgeConfigMode]).
  /// [profileEnabled] enables or disables the profile.
  /// [resetConfig] when true, resets config before applying.
  /// [pluginConfigurations] list of plugin configurations for this profile.
  /// [appAssociations] list of app associations for this profile.
  /// [dataCapturePlus] optional DataCapture Plus configuration.
  /// [enterpriseKeyboard] optional Enterprise Keyboard configuration.
  const DataWedgeProfileConfiguration({
    required this.profileName,
    this.configMode = DataWedgeConfigMode.createIfNotExist,
    this.profileEnabled,
    this.resetConfig,
    this.pluginConfigurations = const <DataWedgePluginConfiguration>[],
    this.appAssociations = const <DataWedgeAppAssociation>[],
    this.dataCapturePlus,
    this.enterpriseKeyboard,
  });

  /// The name of the profile.
  final String profileName;

  /// How the profile configuration should be applied.
  final String configMode;

  /// Whether the profile is enabled.
  final bool? profileEnabled;

  /// Whether to reset the configuration before applying.
  final bool? resetConfig;

  /// Plugin configurations for this profile.
  final List<DataWedgePluginConfiguration> pluginConfigurations;

  /// App associations for this profile.
  final List<DataWedgeAppAssociation> appAssociations;

  /// DataCapture Plus configuration (optional).
  final Map<String, dynamic>? dataCapturePlus;

  /// Enterprise Keyboard configuration (optional).
  final Map<String, dynamic>? enterpriseKeyboard;

  /// Converts this configuration to a Map for DataWedge.
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = <String, dynamic>{
      DataWedgeApi.profileNameKey: profileName,
      DataWedgeApi.configModeKey: configMode,
    };

    if (profileEnabled != null) {
      map[DataWedgeApi.profileEnabledKey] = dataWedgeBool(profileEnabled!);
    }
    if (resetConfig != null) {
      map[DataWedgeApi.resetConfigKey] = dataWedgeBool(resetConfig!);
    }
    if (pluginConfigurations.isNotEmpty) {
      map[DataWedgeApi.pluginConfigKey] =
          pluginConfigurations.map<Map<String, dynamic>>((
        DataWedgePluginConfiguration plugin,
      ) {
        return plugin.toMap();
      }).toList();
    }
    if (appAssociations.isNotEmpty) {
      map[DataWedgeApi.appListKey] =
          appAssociations.map<Map<String, dynamic>>((
        DataWedgeAppAssociation association,
      ) {
        return association.toMap();
      }).toList();
    }
    if (dataCapturePlus != null) {
      map[DataWedgePluginName.dcp] = dataCapturePlus;
    }
    if (enterpriseKeyboard != null) {
      map[DataWedgePluginName.ekb] = enterpriseKeyboard;
    }

    return map;
  }
}

/// Builder class for creating [DataWedgeProfileConfiguration] objects.
///
/// This provides a fluent API for constructing profile configurations.
///
/// Example:
/// ```dart
/// final config = DataWedgeProfileBuilder(profileName: 'MyProfile')
///   .setProfileEnabled(true)
///   .addPlugin(DataWedgePluginConfiguration(
///     pluginName: DataWedgePluginName.barcode,
///     paramList: {'scanner_selection': 'auto'},
///   ))
///   .addAppAssociation(DataWedgeAppAssociation(
///     packageName: 'com.example.myapp',
///   ))
///   .build();
/// ```
class DataWedgeProfileBuilder {
  /// Creates a new profile builder.
  ///
  /// [profileName] is the name of the profile.
  /// [configMode] determines how the config is applied.
  DataWedgeProfileBuilder({
    required this.profileName,
    this.configMode = DataWedgeConfigMode.createIfNotExist,
  });

  /// The name of the profile being built.
  final String profileName;

  /// How the profile configuration should be applied.
  final String configMode;

  bool? _profileEnabled;
  bool? _resetConfig;
  final List<DataWedgePluginConfiguration> _plugins =
      <DataWedgePluginConfiguration>[];
  final List<DataWedgeAppAssociation> _appAssociations =
      <DataWedgeAppAssociation>[];
  Map<String, dynamic>? _dcp;
  Map<String, dynamic>? _ekb;

  /// Sets whether the profile is enabled.
  DataWedgeProfileBuilder setProfileEnabled(bool enabled) {
    _profileEnabled = enabled;
    return this;
  }

  /// Sets whether to reset the configuration before applying.
  DataWedgeProfileBuilder setResetConfig(bool reset) {
    _resetConfig = reset;
    return this;
  }

  /// Adds a plugin configuration to the profile.
  DataWedgeProfileBuilder addPlugin(DataWedgePluginConfiguration plugin) {
    _plugins.add(plugin);
    return this;
  }

  /// Adds an app association to the profile.
  DataWedgeProfileBuilder addAppAssociation(DataWedgeAppAssociation association) {
    _appAssociations.add(association);
    return this;
  }

  /// Sets the DataCapture Plus configuration.
  DataWedgeProfileBuilder setDataCapturePlus(Map<String, dynamic> dcp) {
    _dcp = dcp;
    return this;
  }

  /// Sets the Enterprise Keyboard configuration.
  DataWedgeProfileBuilder setEnterpriseKeyboard(Map<String, dynamic> ekb) {
    _ekb = ekb;
    return this;
  }

  /// Builds and returns the [DataWedgeProfileConfiguration].
  DataWedgeProfileConfiguration build() {
    return DataWedgeProfileConfiguration(
      profileName: profileName,
      configMode: configMode,
      profileEnabled: _profileEnabled,
      resetConfig: _resetConfig,
      pluginConfigurations: List<DataWedgePluginConfiguration>.unmodifiable(
        _plugins,
      ),
      appAssociations: List<DataWedgeAppAssociation>.unmodifiable(
        _appAssociations,
      ),
      dataCapturePlus: _dcp,
      enterpriseKeyboard: _ekb,
    );
  }
}

/// Request for exporting DataWedge configuration.
class DataWedgeExportConfigRequest {
  /// Creates a new export config request.
  ///
  /// [folderPath] is the path where config files will be exported.
  /// [exportType] is the type of export (use [DataWedgeExportType] constants).
  /// [profileName] optionally specifies a single profile to export.
  const DataWedgeExportConfigRequest({
    required this.folderPath,
    required this.exportType,
    this.profileName,
  });

  /// The folder path for exporting config files.
  final String folderPath;

  /// The type of export (profile config or full config).
  final String exportType;

  /// Optional profile name to export (exports all if null).
  final String? profileName;

  /// Converts this request to a Map for DataWedge.
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = <String, dynamic>{
      'FOLDER_PATH': folderPath,
      'EXPORT_TYPE': exportType,
    };

    if (profileName != null && profileName!.isNotEmpty) {
      map[DataWedgeApi.profileNameKey] = profileName;
    }

    return map;
  }
}

/// Request for importing DataWedge configuration.
class DataWedgeImportConfigRequest {
  /// Creates a new import config request.
  ///
  /// [folderPath] is the path from which to import config files.
  /// [fileList] optionally specifies specific files to import.
  const DataWedgeImportConfigRequest({
    required this.folderPath,
    this.fileList,
  });

  /// The folder path for importing config files.
  final String folderPath;

  /// Optional list of specific files to import.
  final List<String>? fileList;

  /// Converts this request to a Map for DataWedge.
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = <String, dynamic>{
      'FOLDER_PATH': folderPath,
    };

    if (fileList != null && fileList!.isNotEmpty) {
      map['FILE_LIST'] = fileList;
    }

    return map;
  }
}

/// Request for setting the disabled app list.
class DataWedgeDisabledAppListRequest {
  /// Creates a new disabled app list request.
  ///
  /// [configMode] is the update mode (use [DataWedgeDisabledAppListMode] constants).
  /// [appList] is the list of app associations to disable.
  const DataWedgeDisabledAppListRequest({
    required this.configMode,
    this.appList = const <DataWedgeAppAssociation>[],
  });

  /// The mode for updating the disabled app list.
  final String configMode;

  /// The list of apps to disable.
  final List<DataWedgeAppAssociation> appList;

  /// Converts this request to a Map for DataWedge.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      DataWedgeApi.configModeKey: configMode,
      DataWedgeApi.appListKey:
          appList.map<Map<String, dynamic>>((DataWedgeAppAssociation app) {
        return app.toMap();
      }).toList(),
    };
  }
}

/// Request for scale (weight) operations.
class DataWedgeScaleRequest {
  /// Creates a new scale request.
  ///
  /// [deviceIdentifier] is the scale device identifier.
  /// [command] is the scale command (use [DataWedgeScaleCommand] constants).
  const DataWedgeScaleRequest({
    required this.deviceIdentifier,
    required this.command,
  });

  /// The identifier of the scale device.
  final String deviceIdentifier;

  /// The command to send to the scale.
  final String command;

  /// Converts this request to a Map for DataWedge.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'SCALE_CONFIG': <String, dynamic>{
        'DEVICE_IDENTIFIER': deviceIdentifier,
        'COMMAND': command,
      },
    };
  }
}

/// Request for notifying a Bluetooth scanner (LED/beep/vibrate).
class DataWedgeNotificationRequest {
  /// Creates a new notification request.
  ///
  /// [deviceIdentifier] is the scanner device identifier.
  /// [notificationSettings] is a list of notification settings (LED, beep, vibration).
  const DataWedgeNotificationRequest({
    required this.deviceIdentifier,
    required this.notificationSettings,
  });

  /// The identifier of the Bluetooth scanner.
  final String deviceIdentifier;

  /// The notification settings for the scanner.
  final List<int> notificationSettings;

  /// Converts this request to a Map for DataWedge.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'NOTIFICATION_CONFIG': <String, dynamic>{
        'DEVICE_IDENTIFIER': deviceIdentifier,
        'NOTIFICATION_SETTINGS': notificationSettings,
      },
    };
  }
}

/// Request for custom notifications to a Bluetooth scanner.
class DataWedgeCustomNotificationRequest {
  /// Creates a new custom notification request.
  ///
  /// [deviceIdentifier] is the scanner device identifier.
  /// [ledSettings] optional LED notification settings.
  /// [beepSettings] list of beep notification settings.
  /// [vibrationSettings] list of vibration notification settings.
  const DataWedgeCustomNotificationRequest({
    required this.deviceIdentifier,
    this.ledSettings,
    this.beepSettings = const <DataWedgeBeepSettings>[],
    this.vibrationSettings = const <DataWedgeVibrationSettings>[],
  });

  /// The identifier of the Bluetooth scanner.
  final String deviceIdentifier;

  /// LED notification settings (optional).
  final DataWedgeLedSettings? ledSettings;

  /// Beep notification settings.
  final List<DataWedgeBeepSettings> beepSettings;

  /// Vibration notification settings.
  final List<DataWedgeVibrationSettings> vibrationSettings;

  /// Converts this request to a Map for DataWedge.
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> notificationSettings = <String, dynamic>{};

    if (ledSettings != null) {
      notificationSettings['LED_SETTINGS'] = ledSettings!.toMap();
    }
    if (beepSettings.isNotEmpty) {
      notificationSettings['BEEP_SETTINGS'] =
          beepSettings.map<Map<String, dynamic>>((DataWedgeBeepSettings b) {
        return b.toMap();
      }).toList();
    }
    if (vibrationSettings.isNotEmpty) {
      notificationSettings['VIBRATOR_SETTINGS'] = vibrationSettings
          .map<Map<String, dynamic>>((DataWedgeVibrationSettings v) {
        return v.toMap();
      }).toList();
    }

    return <String, dynamic>{
      'NOTIFICATION_CONFIG': <String, dynamic>{
        'DEVICE_IDENTIFIER': deviceIdentifier,
        'NOTIFICATION_SETTINGS': notificationSettings,
      },
    };
  }
}

/// LED notification settings for Bluetooth scanners.
class DataWedgeLedSettings {
  /// Creates new LED settings.
  ///
  /// [color] is the LED color.
  /// [onTime] is the LED on time in milliseconds.
  /// [offTime] is the LED off time in milliseconds.
  /// [repeatCount] is the number of times to repeat the pattern.
  const DataWedgeLedSettings({
    required this.color,
    required this.onTime,
    required this.offTime,
    required this.repeatCount,
  });

  /// The LED color value.
  final int color;

  /// The on time in milliseconds.
  final int onTime;

  /// The off time in milliseconds.
  final int offTime;

  /// The number of times to repeat the pattern.
  final int repeatCount;

  /// Converts these settings to a Map for DataWedge.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'COLOR': color,
      'ON_TIME': onTime,
      'OFF_TIME': offTime,
      'REPEAT_COUNT': repeatCount,
    };
  }
}

/// Beep notification settings for Bluetooth scanners.
class DataWedgeBeepSettings {
  /// Creates new beep settings.
  ///
  /// [frequency] is the beep frequency in Hz.
  /// [onTime] is the beep on time in milliseconds.
  /// [offTime] is the beep off time in milliseconds.
  /// [repeatCount] is the number of times to repeat the beep.
  const DataWedgeBeepSettings({
    required this.frequency,
    required this.onTime,
    required this.offTime,
    required this.repeatCount,
  });

  /// The beep frequency in Hz.
  final int frequency;

  /// The on time in milliseconds.
  final int onTime;

  /// The off time in milliseconds.
  final int offTime;

  /// The number of times to repeat the beep.
  final int repeatCount;

  /// Converts these settings to a Map for DataWedge.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'BEEP_FREQUENCY': frequency,
      'ON_TIME': onTime,
      'OFF_TIME': offTime,
      'REPEAT_COUNT': repeatCount,
    };
  }
}

/// Vibration notification settings for Bluetooth scanners.
class DataWedgeVibrationSettings {
  /// Creates new vibration settings.
  ///
  /// [onTime] is the vibration on time in milliseconds.
  /// [offTime] is the vibration off time in milliseconds.
  /// [repeatCount] is the number of times to repeat the vibration.
  const DataWedgeVibrationSettings({
    required this.onTime,
    required this.offTime,
    required this.repeatCount,
  });

  /// The on time in milliseconds.
  final int onTime;

  /// The off time in milliseconds.
  final int offTime;

  /// The number of times to repeat the vibration.
  final int repeatCount;

  /// Converts these settings to a Map for DataWedge.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'ON_TIME': onTime,
      'OFF_TIME': offTime,
      'REPEAT_COUNT': repeatCount,
    };
  }
}
