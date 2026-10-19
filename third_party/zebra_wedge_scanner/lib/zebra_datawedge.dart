import 'src/models/datawedge_models.dart';
import 'zebra_datawedge_platform_interface.dart';

export 'src/models/datawedge_models.dart';

/// A Flutter plugin for interacting with Zebra DataWedge on Android devices.
///
/// This class provides a high-level API to configure and control Zebra's
/// DataWedge service, which provides barcode scanning and data capture
/// capabilities for Zebra mobile computers.
///
/// Example usage:
/// ```dart
/// final zebra = ZebraDataWedge();
///
/// // Check if DataWedge is available
/// final available = await zebra.isAvailable();
///
/// // Listen to scan events
/// zebra.events.listen((event) {
///   if (event.isScan) {
///     print('Scanned: ${event.scanData}');
///   }
/// });
///
/// // Create and configure a profile
/// await zebra.configureClassicBarcodeProfile(
///   profileName: 'MyProfile',
///   packageName: 'com.example.myapp',
/// );
/// ```
class ZebraDataWedge {
  /// Creates a new [ZebraDataWedge] instance.
  ///
  /// An optional [platform] can be provided for testing or custom implementations.
  ZebraDataWedge({ZebraDataWedgePlatform? platform})
      : _platform = platform ?? ZebraDataWedgePlatform.instance;

  final ZebraDataWedgePlatform _platform;

  /// A stream of raw scan data as [Map<String, dynamic>].
  ///
  /// Each event contains the scanned data with keys like 'data', 'labelType', etc.
  /// Prefer using [events] for typed events instead.
  Stream<Map<String, dynamic>> get scanStream => _platform.events;

  /// A stream of typed [DataWedgeEvent] objects.
  ///
  /// This stream emits events for scans, command results, and notifications
  /// from the DataWedge service. Use the [DataWedgeEvent.isScan],
  /// [DataWedgeEvent.isCommandResult], and [DataWedgeEvent.isNotification]
  /// getters to filter event types.
  Stream<DataWedgeEvent> get events {
    return _platform.events.map<DataWedgeEvent>(DataWedgeEvent.fromMap);
  }

  /// Checks if the Zebra DataWedge service is available on the device.
  ///
  /// Returns `true` if DataWedge is installed and available, `false` otherwise.
  Future<bool> isAvailable() {
    return _platform.isDataWedgeAvailable();
  }

  /// Creates or updates a DataWedge profile with the given [profileName].
  ///
  /// This method will create the profile if it doesn't exist, or update
  /// the existing profile configuration.
  Future<void> configureProfile(String profileName) {
    return _platform.configureProfile(profileName);
  }

  /// Switches DataWedge to use the specified [profileName].
  ///
  /// The profile must already exist. Use [configureProfile] or
  /// [configureClassicBarcodeProfile] to create one first.
  Future<void> switchToProfile(String profileName) {
    return _platform.switchToProfile(profileName);
  }

  /// Starts a software scan trigger (initiates barcode scanning).
  ///
  /// This is equivalent to pressing the hardware scan button.
  /// Use [stopSoftScan] or [toggleSoftScan] to control the scan session.
  Future<void> startSoftScan() {
    return _platform.startSoftScan();
  }

  /// Stops an ongoing software scan session.
  ///
  /// Call this after [startSoftScan] when you want to stop scanning.
  Future<void> stopSoftScan() {
    return sendCommand(
      command: DataWedgeApi.softScanTrigger,
      value: DataWedgeSoftScanAction.stop,
      commandTag: 'SOFT_SCAN_STOP',
    );
  }

  /// Toggles the software scan trigger state.
  ///
  /// If scanning is active, it will stop. If inactive, it will start.
  Future<void> toggleSoftScan() {
    return sendCommand(
      command: DataWedgeApi.softScanTrigger,
      value: DataWedgeSoftScanAction.toggle,
      commandTag: 'SOFT_SCAN_TOGGLE',
    );
  }

  /// Enables the barcode scanner.
  ///
  /// The scanner must be enabled before it can receive scan triggers.
  Future<void> enableScanner() {
    return _platform.enableScanner();
  }

  /// Disables the barcode scanner.
  ///
  /// After calling this, the scanner will not respond to scan triggers
  /// until [enableScanner] is called.
  Future<void> disableScanner() {
    return _platform.disableScanner();
  }

  /// Registers for notifications of the specified [notificationType].
  ///
  /// Available notification types are defined in [DataWedgeNotificationType]:
  /// - [DataWedgeNotificationType.scannerStatus]: Scanner state changes
  /// - [DataWedgeNotificationType.profileSwitch]: Profile change events
  /// - [DataWedgeNotificationType.configurationUpdate]: Config changes
  /// - [DataWedgeNotificationType.workflowStatus]: Workflow state changes
  Future<void> registerForNotification(String notificationType) {
    return _platform.registerForNotification(notificationType);
  }

  /// Unregisters from notifications of the specified [notificationType].
  Future<void> unregisterForNotification(String notificationType) {
    return _platform.unregisterForNotification(notificationType);
  }

  /// Retrieves the currently active DataWedge profile name.
  ///
  /// The result will be delivered as a command result event on the [events] stream.
  Future<void> getActiveProfile() {
    return _platform.getActiveProfile();
  }

  /// Retrieves the list of all DataWedge profiles.
  ///
  /// The result will be delivered as a command result event on the [events] stream.
  Future<void> getProfilesList() {
    return _platform.getProfilesList();
  }

  /// Retrieves the DataWedge version information.
  ///
  /// The result will be delivered as a command result event on the [events] stream.
  Future<void> getVersionInfo() {
    return _platform.getVersionInfo();
  }

  /// Enumerates all available scanners on the device.
  ///
  /// The result will be delivered as a command result event on the [events] stream,
  /// containing a list of available scanners with their identifiers and types.
  Future<void> enumerateScanners() {
    return _platform.enumerateScanners();
  }

  /// Creates a new DataWedge profile with the given [profileName].
  ///
  /// Optionally, a [commandTag] can be provided to identify the result
  /// in the command result event. Set [requestResult] to `false` to
  /// avoid receiving a result event.
  Future<void> createProfile(
    String profileName, {
    String? commandTag,
    bool requestResult = true,
  }) {
    return sendCommand(
      command: DataWedgeApi.createProfile,
      value: profileName,
      commandTag: commandTag ?? 'CREATE_PROFILE_$profileName',
      requestResult: requestResult,
    );
  }

  /// Clones an existing profile to a new profile.
  ///
  /// [sourceProfileName] is the name of the existing profile to clone.
  /// [destinationProfileName] is the name for the new cloned profile.
  /// Optionally, a [commandTag] can be provided to identify the result.
  Future<void> cloneProfile({
    required String sourceProfileName,
    required String destinationProfileName,
    String? commandTag,
    bool requestResult = true,
  }) {
    return sendCommand(
      command: DataWedgeApi.cloneProfile,
      value: <String>[sourceProfileName, destinationProfileName],
      commandTag: commandTag ?? 'CLONE_PROFILE_$destinationProfileName',
      requestResult: requestResult,
    );
  }

  /// Renames an existing profile.
  ///
  /// [profileName] is the current name of the profile.
  /// [newProfileName] is the new name to assign.
  /// Optionally, a [commandTag] can be provided to identify the result.
  Future<void> renameProfile({
    required String profileName,
    required String newProfileName,
    String? commandTag,
    bool requestResult = true,
  }) {
    return sendCommand(
      command: DataWedgeApi.renameProfile,
      value: <String>[profileName, newProfileName],
      commandTag: commandTag ?? 'RENAME_PROFILE_$newProfileName',
      requestResult: requestResult,
    );
  }

  /// Deletes one or more DataWedge profiles.
  ///
  /// [profileNames] is a list of profile names to delete.
  /// Use [deleteAllDeletableProfiles] to delete all deletable profiles at once.
  Future<void> deleteProfiles(
    List<String> profileNames, {
    String? commandTag,
    bool requestResult = true,
  }) {
    return sendCommand(
      command: DataWedgeApi.deleteProfile,
      value: profileNames,
      commandTag: commandTag ?? 'DELETE_PROFILE',
      requestResult: requestResult,
    );
  }

  /// Deletes all deletable DataWedge profiles.
  ///
  /// This uses the wildcard '*' to match all profiles that can be deleted.
  /// Use [deleteProfiles] to delete specific profiles.
  Future<void> deleteAllDeletableProfiles({
    String? commandTag,
    bool requestResult = true,
  }) {
    return deleteProfiles(
      const <String>[DataWedgeApi.wildcard],
      commandTag: commandTag ?? 'DELETE_ALL_PROFILES',
      requestResult: requestResult,
    );
  }

  /// Applies a full profile configuration to DataWedge.
  ///
  /// [configuration] is a [DataWedgeProfileConfiguration] object that defines
  /// the complete profile settings including plugins, app associations, etc.
  /// Use [DataWedgeProfileBuilder] to construct the configuration.
  Future<void> setConfig(
    DataWedgeProfileConfiguration configuration, {
    String? commandTag,
    bool requestResult = true,
  }) {
    return sendCommandBundle(
      command: DataWedgeApi.setConfig,
      value: configuration.toMap(),
      commandTag: commandTag ?? 'SET_CONFIG_${configuration.profileName}',
      requestResult: requestResult,
    );
  }

  /// Applies a profile configuration (alias for [setConfig]).
  ///
  /// This method is equivalent to [setConfig] and provided for semantic clarity.
  Future<void> applyProfileConfiguration(
    DataWedgeProfileConfiguration configuration, {
    String? commandTag,
    bool requestResult = true,
  }) {
    return setConfig(
      configuration,
      commandTag: commandTag,
      requestResult: requestResult,
    );
  }

  /// Configures a classic barcode scanning profile with sensible defaults.
  ///
  /// This is a convenience method that sets up a profile with:
  /// - Barcode plugin enabled with auto scanner selection
  /// - Intent output configured for the specified [packageName]
  /// - Keystroke output disabled (to avoid duplicate data)
  /// - App association for the specified [packageName] and [activityList]
  ///
  /// [profileName] is the name for the new profile.
  /// [packageName] is your app's package name (e.g., 'com.example.myapp').
  /// [activityList] specifies which activities the profile applies to.
  /// [intentAction] custom intent action (defaults to '$packageName.SCAN').
  /// [intentCategory] the intent category (defaults to 'android.intent.category.DEFAULT').
  /// [intentDelivery] the intent delivery method (defaults to broadcast).
  /// [registerDefaultNotifications] automatically registers for scanner status,
  /// profile switch, configuration update, and workflow status notifications.
  Future<void> configureClassicBarcodeProfile({
    required String profileName,
    required String packageName,
    List<String> activityList = const <String>[DataWedgeApi.wildcard],
    String? intentAction,
    String intentCategory = DataWedgeApi.defaultIntentCategory,
    int intentDelivery = DataWedgeIntentDelivery.broadcast,
    bool registerDefaultNotifications = true,
    bool requestResult = true,
  }) async {
    final String resolvedIntentAction = intentAction ?? '$packageName.SCAN';

    final DataWedgeProfileConfiguration configuration =
        DataWedgeProfileBuilder(
      profileName: profileName,
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
                  'intent_action': resolvedIntentAction,
                  'intent_category': intentCategory,
                  'intent_delivery': intentDelivery,
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
                packageName: packageName,
                activityList: activityList,
              ),
            )
            .build();

    await setConfig(
      configuration,
      commandTag: 'SET_CONFIG_$profileName',
      requestResult: requestResult,
    );

    if (registerDefaultNotifications) {
      await registerForDefaultNotifications();
    }
  }

  /// Retrieves the configuration of an existing DataWedge profile.
  ///
  /// [profileName] is the name of the profile to retrieve.
  /// [pluginNames] optionally specifies which plugins to retrieve config for.
  /// [processPlugins] optionally specifies process plugins to include.
  /// [includeAppList] when true, includes the app association list.
  /// [includeDataCapturePlus] when true, includes DataCapture Plus config.
  /// [includeEnterpriseKeyboard] when true, includes Enterprise Keyboard config.
  /// [scannerSelectionByIdentifier] optionally filter by scanner identifier.
  ///
  /// The result is delivered as a command result event on the [events] stream.
  Future<void> getConfig({
    required String profileName,
    List<String>? pluginNames,
    List<DataWedgeProcessPluginRequest>? processPlugins,
    bool includeAppList = false,
    bool includeDataCapturePlus = false,
    bool includeEnterpriseKeyboard = false,
    String? scannerSelectionByIdentifier,
    String? commandTag,
    bool requestResult = true,
  }) {
    final Map<String, dynamic> value = <String, dynamic>{
      DataWedgeApi.profileNameKey: profileName,
    };

    if ((pluginNames != null && pluginNames.isNotEmpty) ||
        (processPlugins != null && processPlugins.isNotEmpty)) {
      final Map<String, dynamic> pluginConfig = <String, dynamic>{};

      if (pluginNames != null && pluginNames.isNotEmpty) {
        pluginConfig[DataWedgeApi.pluginNameKey] =
            pluginNames.length == 1 ? pluginNames.first : pluginNames;
      }

      if (processPlugins != null && processPlugins.isNotEmpty) {
        pluginConfig[DataWedgeApi.processPluginNameKey] =
            processPlugins.map<Map<String, dynamic>>((
          DataWedgeProcessPluginRequest processPlugin,
        ) {
          return processPlugin.toMap();
        }).toList();
      }

      value[DataWedgeApi.pluginConfigKey] = pluginConfig;
    }

    if (includeAppList) {
      value[DataWedgeApi.appListKey] = '';
    }
    if (includeDataCapturePlus) {
      value[DataWedgePluginName.dcp] = '';
    }
    if (includeEnterpriseKeyboard) {
      value[DataWedgePluginName.ekb] = '';
    }
    if (scannerSelectionByIdentifier != null &&
        scannerSelectionByIdentifier.isNotEmpty) {
      value[DataWedgeApi.scannerSelectionByIdentifier] =
          scannerSelectionByIdentifier;
    }

    return sendCommandBundle(
      command: DataWedgeApi.getConfig,
      value: value,
      commandTag: commandTag ?? 'GET_CONFIG_$profileName',
      requestResult: requestResult,
    );
  }

  /// Sets the specified profile as the default DataWedge profile.
  ///
  /// [profileName] is the name of the profile to set as default.
  /// The default profile is used when no other profile matches the current app.
  Future<void> setDefaultProfile(
    String profileName, {
    String? commandTag,
    bool requestResult = true,
  }) {
    return sendCommand(
      command: DataWedgeApi.setDefaultProfile,
      value: profileName,
      commandTag: commandTag ?? 'SET_DEFAULT_PROFILE_$profileName',
      requestResult: requestResult,
    );
  }

  /// Resets the default profile to the DataWedge system default.
  Future<void> resetDefaultProfile({
    String? commandTag,
    bool requestResult = true,
  }) {
    return sendCommand(
      command: DataWedgeApi.resetDefaultProfile,
      value: '',
      commandTag: commandTag ?? 'RESET_DEFAULT_PROFILE',
      requestResult: requestResult,
    );
  }

  /// Imports DataWedge configuration from files.
  ///
  /// [request] specifies the folder path and optional file list to import.
  /// Use [DataWedgeImportConfigRequest] to configure the import.
  Future<void> importConfig(
    DataWedgeImportConfigRequest request, {
    String? commandTag,
    bool requestResult = true,
  }) {
    return sendCommandBundle(
      command: DataWedgeApi.importConfig,
      value: request.toMap(),
      commandTag: commandTag ?? 'IMPORT_CONFIG',
      requestResult: requestResult,
    );
  }

  /// Exports DataWedge configuration to files.
  ///
  /// [request] specifies the folder path, export type, and optional profile name.
  /// Use [DataWedgeExportConfigRequest] to configure the export.
  Future<void> exportConfig(
    DataWedgeExportConfigRequest request, {
    String? commandTag,
    bool requestResult = true,
  }) {
    return sendCommandBundle(
      command: DataWedgeApi.exportConfig,
      value: request.toMap(),
      commandTag: commandTag ?? 'EXPORT_CONFIG',
      requestResult: requestResult,
    );
  }

  /// Sets the list of apps where DataWedge should be disabled.
  ///
  /// [request] specifies the configuration mode and list of apps.
  /// Use [DataWedgeDisabledAppListRequest] to configure which apps
  /// should have DataWedge disabled.
  Future<void> setDisabledAppList(
    DataWedgeDisabledAppListRequest request, {
    String? commandTag,
    bool requestResult = true,
  }) {
    return sendCommandBundle(
      command: DataWedgeApi.setDisabledAppList,
      value: request.toMap(),
      commandTag: commandTag ?? 'SET_DISABLED_APP_LIST',
      requestResult: requestResult,
    );
  }

  /// Retrieves the list of apps where DataWedge is disabled.
  ///
  /// The result is delivered as a command result event on the [events] stream.
  Future<void> getDisabledAppList({
    String? commandTag,
    bool requestResult = true,
  }) {
    return _sendQueryCommand(
      command: DataWedgeApi.getDisabledAppList,
      commandTag: commandTag ?? 'GET_DISABLED_APP_LIST',
      requestResult: requestResult,
    );
  }

  /// Sets whether DataWedge should ignore disabled profiles.
  ///
  /// When [ignoreDisabledProfiles] is true, disabled profiles are skipped
  /// during profile selection.
  Future<void> setIgnoreDisabledProfiles(
    bool ignoreDisabledProfiles, {
    String? commandTag,
    bool requestResult = true,
  }) {
    return sendCommand(
      command: DataWedgeApi.setIgnoreDisabledProfiles,
      value: dataWedgeBool(ignoreDisabledProfiles),
      commandTag: commandTag ?? 'SET_IGNORE_DISABLED_PROFILES',
      requestResult: requestResult,
    );
  }

  /// Retrieves whether DataWedge ignores disabled profiles.
  ///
  /// The result is delivered as a command result event on the [events] stream.
  Future<void> getIgnoreDisabledProfiles({
    String? commandTag,
    bool requestResult = true,
  }) {
    return _sendQueryCommand(
      command: DataWedgeApi.getIgnoreDisabledProfiles,
      commandTag: commandTag ?? 'GET_IGNORE_DISABLED_PROFILES',
      requestResult: requestResult,
    );
  }

  /// Enables or disables the DataWedge service.
  ///
  /// When [enabled] is true, DataWedge is enabled and can process scans.
  /// When false, DataWedge is completely disabled.
  Future<void> setDataWedgeEnabled(
    bool enabled, {
    String? commandTag,
    bool requestResult = true,
  }) {
    return sendCommand(
      command: DataWedgeApi.enableDataWedge,
      value: enabled,
      commandTag: commandTag ?? (enabled ? 'ENABLE_DATAWEDGE' : 'DISABLE_DATAWEDGE'),
      requestResult: requestResult,
    );
  }

  /// Retrieves the current DataWedge service status.
  ///
  /// The result is delivered as a command result event on the [events] stream.
  Future<void> getDataWedgeStatus({
    String? commandTag,
    bool requestResult = true,
  }) {
    return _sendQueryCommand(
      command: DataWedgeApi.getDataWedgeStatus,
      commandTag: commandTag ?? 'GET_DATAWEDGE_STATUS',
      requestResult: requestResult,
    );
  }

  /// Retrieves the current scanner status.
  ///
  /// The result is delivered as a command result event on the [events] stream,
  /// indicating whether the scanner is idle, scanning, waiting, etc.
  Future<void> getScannerStatus({
    String? commandTag,
    bool requestResult = true,
  }) {
    return _sendQueryCommand(
      command: DataWedgeApi.getScannerStatus,
      commandTag: commandTag ?? 'GET_SCANNER_STATUS',
      requestResult: requestResult,
    );
  }

  /// Enumerates all available trigger sources on the device.
  ///
  /// The result is delivered as a command result event on the [events] stream,
  /// listing all hardware and software triggers.
  Future<void> enumerateTriggers({
    String? commandTag,
    bool requestResult = true,
  }) {
    return _sendQueryCommand(
      command: DataWedgeApi.enumerateTriggers,
      commandTag: commandTag ?? 'ENUMERATE_TRIGGERS',
      requestResult: requestResult,
    );
  }

  /// Enumerates all available workflows on the device.
  ///
  /// The result is delivered as a command result event on the [events] stream,
  /// listing all configured workflow profiles.
  Future<void> enumerateWorkflows({
    String? commandTag,
    bool requestResult = true,
  }) {
    return _sendQueryCommand(
      command: DataWedgeApi.enumerateWorkflows,
      commandTag: commandTag ?? 'ENUMERATE_WORKFLOWS',
      requestResult: requestResult,
    );
  }

  /// Controls the software scan trigger with optional scanner selection.
  ///
  /// [action] specifies the trigger action. Use values from
  /// [DataWedgeSoftTriggerAction] (start, stop, toggle).
  /// [scannerSelectionByIdentifier] optionally specifies which scanner to control.
  Future<void> softScanTrigger({
    required String action,
    String? scannerSelectionByIdentifier,
    String? commandTag,
    bool requestResult = true,
  }) {
    if (scannerSelectionByIdentifier == null ||
        scannerSelectionByIdentifier.isEmpty) {
      return sendCommand(
        command: DataWedgeApi.softScanTrigger,
        value: action,
        commandTag: commandTag ?? 'SOFT_SCAN_TRIGGER',
        requestResult: requestResult,
      );
    }

    return sendIntent(
      extras: <String, dynamic>{
        DataWedgeApi.scannerSelectionByIdentifier: scannerSelectionByIdentifier,
        DataWedgeApi.softScanTrigger: action,
      },
      targetPackage: DataWedgeApi.dataWedgePackage,
      commandTag: commandTag ?? 'SOFT_SCAN_TRIGGER',
      requestResult: requestResult,
    );
  }

  /// Controls the software RFID trigger.
  ///
  /// [action] specifies the trigger action. Use values from
  /// [DataWedgeSoftTriggerAction] (start, stop, toggle).
  Future<void> softRfidTrigger({
    required String action,
    String? commandTag,
    bool requestResult = true,
  }) {
    return sendCommand(
      command: DataWedgeApi.softRfidTrigger,
      value: action,
      commandTag: commandTag ?? 'SOFT_RFID_TRIGGER',
      requestResult: requestResult,
    );
  }

  /// Controls the software voice trigger for voice input workflows.
  ///
  /// [action] specifies the trigger action (start, stop, toggle).
  /// [pluginName] is the voice plugin name (defaults to [DataWedgePluginName.voice]).
  Future<void> softVoiceTrigger({
    required String action,
    String pluginName = DataWedgePluginName.voice,
    String? commandTag,
    bool requestResult = true,
  }) {
    return sendIntent(
      extras: <String, dynamic>{
        DataWedgeApi.pluginNameKey: pluginName,
        DataWedgeApi.softTrigger: action,
      },
      targetPackage: DataWedgeApi.dataWedgePackage,
      commandTag: commandTag ?? 'SOFT_TRIGGER',
      requestResult: requestResult,
    );
  }

  /// Sends a generic scanner input plugin command.
  ///
  /// [action] specifies the plugin action. Use values from
  /// [DataWedgeScannerInputAction] for enable, disable, suspend, or resume.
  Future<void> scannerInputPlugin(
    String action, {
    String? commandTag,
    bool requestResult = true,
  }) {
    return sendCommand(
      command: DataWedgeApi.scannerInputPlugin,
      value: action,
      commandTag: commandTag ?? 'SCANNER_INPUT_PLUGIN',
      requestResult: requestResult,
    );
  }

  /// Suspends the scanner plugin (temporarily disables scanning).
  ///
  /// Call [resumeScanner] to re-enable scanning.
  Future<void> suspendScanner({
    String? commandTag,
    bool requestResult = true,
  }) {
    return scannerInputPlugin(
      DataWedgeScannerInputAction.suspendPlugin,
      commandTag: commandTag ?? 'SUSPEND_SCANNER_PLUGIN',
      requestResult: requestResult,
    );
  }

  /// Resumes a suspended scanner plugin.
  ///
  /// Call this after [suspendScanner] to re-enable scanning.
  Future<void> resumeScanner({
    String? commandTag,
    bool requestResult = true,
  }) {
    return scannerInputPlugin(
      DataWedgeScannerInputAction.resumePlugin,
      commandTag: commandTag ?? 'RESUME_SCANNER_PLUGIN',
      requestResult: requestResult,
    );
  }

  /// Switches to a scanner by its numeric index.
  ///
  /// [scannerIndex] is the index of the scanner as reported by
  /// [enumerateScanners].
  Future<void> switchScannerByIndex(
    int scannerIndex, {
    String? commandTag,
    bool requestResult = true,
  }) {
    return sendCommand(
      command: DataWedgeApi.switchScanner,
      value: scannerIndex.toString(),
      commandTag: commandTag ?? 'SWITCH_SCANNER_INDEX_$scannerIndex',
      requestResult: requestResult,
    );
  }

  /// Switches to a scanner by its identifier string.
  ///
  /// [scannerIdentifier] is the scanner identifier (e.g.,
  /// [DataWedgeScannerIdentifier.internalImager], [DataWedgeScannerIdentifier.bluetoothRs6000]).
  Future<void> switchScannerByIdentifier(
    String scannerIdentifier, {
    String? commandTag,
    bool requestResult = true,
  }) {
    return sendCommand(
      command: DataWedgeApi.switchScannerEx,
      value: scannerIdentifier,
      commandTag: commandTag ?? 'SWITCH_SCANNER_$scannerIdentifier',
      requestResult: requestResult,
    );
  }

  /// Updates scanner parameters for the currently active scanner.
  ///
  /// [parameters] is a map of parameter names to values.
  /// [scannerSelectionByIdentifier] optionally specifies which scanner to configure.
  Future<void> switchScannerParams({
    required Map<String, dynamic> parameters,
    String? scannerSelectionByIdentifier,
    String? commandTag,
    bool requestResult = true,
  }) {
    return sendIntent(
      extras: <String, dynamic>{
        if (scannerSelectionByIdentifier != null &&
            scannerSelectionByIdentifier.isNotEmpty)
          DataWedgeApi.scannerSelectionByIdentifier: scannerSelectionByIdentifier,
        DataWedgeApi.switchScannerParams: parameters,
      },
      targetPackage: DataWedgeApi.dataWedgePackage,
      commandTag: commandTag ?? 'SWITCH_SCANNER_PARAMS',
      requestResult: requestResult,
    );
  }

  /// Switches the active data capture plugin.
  ///
  /// [targetPlugin] is the plugin to switch to (e.g., [DataWedgePluginName.barcode]).
  /// [paramList] optionally provides parameters for the target plugin.
  /// [includeApplicationPackage] when true, includes the app package in the intent.
  Future<void> switchDataCapture({
    required String targetPlugin,
    Map<String, dynamic>? paramList,
    String? commandTag,
    bool requestResult = true,
    bool includeApplicationPackage = true,
  }) {
    return sendIntent(
      extras: <String, dynamic>{
        DataWedgeApi.switchDataCapture: targetPlugin,
        if (paramList != null && paramList.isNotEmpty)
          DataWedgeApi.paramListKey: paramList,
      },
      targetPackage: DataWedgeApi.dataWedgePackage,
      commandTag: commandTag ?? 'SWITCH_DATACAPTURE_$targetPlugin',
      requestResult: requestResult,
      includeApplicationPackage: includeApplicationPackage,
    );
  }

  /// Registers for all default notification types.
  ///
  /// This registers for:
  /// - Scanner status changes
  /// - Profile switch events
  /// - Configuration update events
  /// - Workflow status changes
  ///
  /// This is typically called after configuring a profile.
  Future<void> registerForDefaultNotifications() async {
    const List<String> notificationTypes = <String>[
      DataWedgeNotificationType.scannerStatus,
      DataWedgeNotificationType.profileSwitch,
      DataWedgeNotificationType.configurationUpdate,
      DataWedgeNotificationType.workflowStatus,
    ];

    for (final String notificationType in notificationTypes) {
      await registerForNotification(notificationType);
    }
  }

  /// Retrieves the weight from a connected scale device.
  ///
  /// [deviceIdentifier] specifies the scale device (defaults to
  /// [DataWedgeScannerIdentifier.usbTgcsMp7000]).
  /// The result is delivered as a command result event on the [events] stream.
  Future<void> getWeight({
    String deviceIdentifier = DataWedgeScannerIdentifier.usbTgcsMp7000,
    String? commandTag,
    bool requestResult = true,
  }) {
    return sendCommandBundle(
      command: DataWedgeApi.scale,
      value: DataWedgeScaleRequest(
        deviceIdentifier: deviceIdentifier,
        command: DataWedgeScaleCommand.getWeight,
      ).toMap(),
      commandTag: commandTag ?? 'GET_WEIGHT',
      requestResult: requestResult,
    );
  }

  /// Sets the connected scale device to zero (tare).
  ///
  /// [deviceIdentifier] specifies the scale device (defaults to
  /// [DataWedgeScannerIdentifier.usbTgcsMp7000]).
  Future<void> setScaleToZero({
    String deviceIdentifier = DataWedgeScannerIdentifier.usbTgcsMp7000,
    String? commandTag,
    bool requestResult = true,
  }) {
    return sendCommandBundle(
      command: DataWedgeApi.scale,
      value: DataWedgeScaleRequest(
        deviceIdentifier: deviceIdentifier,
        command: DataWedgeScaleCommand.setScaleToZero,
      ).toMap(),
      commandTag: commandTag ?? 'SET_SCALE_TO_ZERO',
      requestResult: requestResult,
    );
  }

  /// Sends a notification request to a Bluetooth scanner.
  ///
  /// [request] specifies the device identifier and notification settings.
  /// Use [DataWedgeNotificationRequest] to configure LED, beep, or vibration notifications.
  Future<void> notifyBluetoothScanner(
    DataWedgeNotificationRequest request, {
    String? commandTag,
    bool requestResult = true,
  }) {
    return sendCommandBundle(
      command: DataWedgeApi.notify,
      value: request.toMap(),
      commandTag: commandTag ?? 'NOTIFY_SCANNER',
      requestResult: requestResult,
    );
  }

  /// Sends a custom notification request to a Bluetooth scanner.
  ///
  /// [request] specifies custom LED, beep, and vibration settings.
  /// Use [DataWedgeCustomNotificationRequest] for full control over notification behavior.
  Future<void> customNotifyBluetoothScanner(
    DataWedgeCustomNotificationRequest request, {
    String? commandTag,
    bool requestResult = true,
  }) {
    return sendCommandBundle(
      command: DataWedgeApi.notify,
      value: request.toMap(),
      commandTag: commandTag ?? 'CUSTOM_NOTIFY_SCANNER',
      requestResult: requestResult,
    );
  }

  /// Sends a generic command to DataWedge.
  ///
  /// [command] is the DataWedge API command string.
  /// [value] is the command parameter (can be String, List, or Map).
  /// [commandTag] optionally identifies this command in result events.
  /// [requestResult] when true, a result event will be emitted on the [events] stream.
  Future<void> sendCommand({
    required String command,
    dynamic value,
    String? commandTag,
    bool requestResult = true,
  }) {
    return _platform.sendCommand(
      command: command,
      value: value,
      commandTag: commandTag,
      requestResult: requestResult,
    );
  }

  /// Sends a command with a Map value to DataWedge.
  ///
  /// Use this for commands that require complex configuration objects
  /// (e.g., [DataWedgeApi.setConfig], [DataWedgeApi.getConfig]).
  ///
  /// [command] is the DataWedge API command string.
  /// [value] is the configuration Map to send.
  /// [commandTag] optionally identifies this command in result events.
  /// [requestResult] when true, a result event will be emitted on the [events] stream.
  Future<void> sendCommandBundle({
    required String command,
    required Map<String, dynamic> value,
    String? commandTag,
    bool requestResult = true,
  }) {
    return _platform.sendCommandBundle(
      command: command,
      value: value,
      commandTag: commandTag,
      requestResult: requestResult,
    );
  }

  /// Sends a custom intent to DataWedge or another package.
  ///
  /// [extras] contains the intent extras (key-value pairs).
  /// [action] optionally specifies the intent action.
  /// [targetPackage] optionally specifies the target package (defaults to DataWedge).
  /// [commandTag] optionally identifies this command in result events.
  /// [orderedBroadcast] when true, uses ordered broadcast instead of normal broadcast.
  /// [includeApplicationPackage] when true, includes the app package name in the intent.
  Future<void> sendIntent({
    required Map<String, dynamic> extras,
    String? action,
    String? targetPackage,
    String? commandTag,
    bool requestResult = true,
    bool orderedBroadcast = false,
    bool includeApplicationPackage = false,
  }) {
    return _platform.sendIntent(
      extras: extras,
      action: action,
      targetPackage: targetPackage,
      commandTag: commandTag,
      requestResult: requestResult,
      orderedBroadcast: orderedBroadcast,
      includeApplicationPackage: includeApplicationPackage,
    );
  }

  /// Internal helper to send a query command that expects a result.
  Future<void> _sendQueryCommand({
    required String command,
    required String commandTag,
    bool requestResult = true,
  }) {
    return sendCommand(
      command: command,
      value: '',
      commandTag: commandTag,
      requestResult: requestResult,
    );
  }
}
