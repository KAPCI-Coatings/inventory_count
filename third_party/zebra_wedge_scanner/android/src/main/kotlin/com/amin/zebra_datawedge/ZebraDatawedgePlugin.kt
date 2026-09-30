package com.amin.zebra_datawedge

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.os.Parcelable
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** ZebraDatawedgePlugin */
class ZebraDatawedgePlugin : FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {
  companion object {
    private const val methodChannelName = "zebra_datawedge/methods"
    private const val eventChannelName = "zebra_datawedge/scans"

    private const val dataWedgeAction = "com.symbol.datawedge.api.ACTION"
    private const val dataWedgeResultAction = "com.symbol.datawedge.api.RESULT_ACTION"
    private const val dataWedgeNotificationAction = "com.symbol.datawedge.api.NOTIFICATION_ACTION"
    private const val dataWedgeCreateProfile = "com.symbol.datawedge.api.CREATE_PROFILE"
    private const val dataWedgeSetConfig = "com.symbol.datawedge.api.SET_CONFIG"
    private const val dataWedgeGetConfig = "com.symbol.datawedge.api.GET_CONFIG"
    private const val dataWedgeSwitchToProfile = "com.symbol.datawedge.api.SWITCH_TO_PROFILE"
    private const val dataWedgeSetDefaultProfile = "com.symbol.datawedge.api.SET_DEFAULT_PROFILE"
    private const val dataWedgeSoftScanTrigger = "com.symbol.datawedge.api.SOFT_SCAN_TRIGGER"
    private const val dataWedgeScannerInputPlugin = "com.symbol.datawedge.api.SCANNER_INPUT_PLUGIN"
    private const val dataWedgeGetActiveProfile = "com.symbol.datawedge.api.GET_ACTIVE_PROFILE"
    private const val dataWedgeGetProfilesList = "com.symbol.datawedge.api.GET_PROFILES_LIST"
    private const val dataWedgeGetVersionInfo = "com.symbol.datawedge.api.GET_VERSION_INFO"
    private const val dataWedgeEnumerateScanners = "com.symbol.datawedge.api.ENUMERATE_SCANNERS"
    private const val dataWedgeRegisterForNotification =
      "com.symbol.datawedge.api.REGISTER_FOR_NOTIFICATION"
    private const val dataWedgeUnregisterForNotification =
      "com.symbol.datawedge.api.UNREGISTER_FOR_NOTIFICATION"
    private const val scannerEnablePlugin = "ENABLE_PLUGIN"
    private const val scannerDisablePlugin = "DISABLE_PLUGIN"

    private const val dataWedgeSendResult = "SEND_RESULT"
    private const val dataWedgeSendResultMode = "COMPLETE_RESULT"
    private const val dataWedgeCommandIdentifier = "COMMAND_IDENTIFIER"
    private const val dataWedgeResult = "RESULT"
    private const val dataWedgeCommand = "COMMAND"
    private const val dataWedgeResultInfo = "RESULT_INFO"
    private const val dataWedgeNotification = "com.symbol.datawedge.api.NOTIFICATION"
    private const val dataWedgeNotificationType = "NOTIFICATION_TYPE"
    private const val dataWedgeNotificationStatus = "STATUS"
    private const val dataWedgeProfileName = "PROFILE_NAME"
    private const val dataWedgeApplicationName = "APPLICATION_NAME"

    private const val scanDataKey = "com.symbol.datawedge.data_string"
    private const val legacyScanDataKey = "com.motorolasolutions.emdk.datawedge.data_string"
    private const val scanLabelTypeKey = "com.symbol.datawedge.label_type"
  }

  private lateinit var methodChannel: MethodChannel
  private lateinit var eventChannel: EventChannel
  private lateinit var appContext: Context

  private var eventSink: EventChannel.EventSink? = null
  private var receiverRegistered = false
  private var commandSequence = 0
  private var scanIntentAction: String = "com.example.app.SCAN"

  private val scanReceiver = object : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
      when (intent?.action) {
        scanIntentAction,
        "com.basicintent.ACTION" -> handleScanIntent(intent)
        dataWedgeResultAction -> handleResultIntent(intent)
        dataWedgeNotificationAction -> handleNotificationIntent(intent)
      }
    }
  }

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    appContext = binding.applicationContext
    scanIntentAction = "${appContext.packageName}.SCAN"

    methodChannel = MethodChannel(binding.binaryMessenger, methodChannelName)
    eventChannel = EventChannel(binding.binaryMessenger, eventChannelName)
    methodChannel.setMethodCallHandler(this)
    eventChannel.setStreamHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "isDataWedgeAvailable" -> {
        result.success(isDataWedgeAvailable())
      }

      "configureProfile" -> {
        val profileName = call.argument<String>("profileName") ?: "MC930B_PROFILE"
        configureDataWedgeProfile(profileName)
        result.success(true)
      }

      "switchToProfile" -> {
        val profileName = call.argument<String>("profileName") ?: "MC930B_PROFILE"
        sendDataWedgeCommand(dataWedgeSwitchToProfile, profileName)
        result.success(true)
      }

      "startSoftScan" -> {
        sendDataWedgeCommand(dataWedgeSoftScanTrigger, "START_SCANNING")
        result.success(true)
      }

      "enableScanner" -> {
        sendDataWedgeCommand(
          extra = dataWedgeScannerInputPlugin,
          value = scannerEnablePlugin,
          commandTag = "ENABLE_SCANNER_PLUGIN"
        )
        result.success(true)
      }

      "disableScanner" -> {
        sendDataWedgeCommand(
          extra = dataWedgeScannerInputPlugin,
          value = scannerDisablePlugin,
          commandTag = "DISABLE_SCANNER_PLUGIN"
        )
        result.success(true)
      }

      "registerForNotification" -> {
        val type = call.argument<String>("notificationType") ?: "SCANNER_STATUS"
        registerForNotification(type)
        result.success(true)
      }

      "unregisterForNotification" -> {
        val type = call.argument<String>("notificationType") ?: "SCANNER_STATUS"
        unregisterForNotification(type)
        result.success(true)
      }

      "getActiveProfile" -> {
        sendDataWedgeCommand(
          extra = dataWedgeGetActiveProfile,
          value = "",
          commandTag = "GET_ACTIVE_PROFILE"
        )
        result.success(true)
      }

      "getProfilesList" -> {
        sendDataWedgeCommand(
          extra = dataWedgeGetProfilesList,
          value = "",
          commandTag = "GET_PROFILES_LIST"
        )
        result.success(true)
      }

      "getVersionInfo" -> {
        sendDataWedgeCommand(
          extra = dataWedgeGetVersionInfo,
          value = "",
          commandTag = "GET_VERSION_INFO"
        )
        result.success(true)
      }

      "enumerateScanners" -> {
        sendDataWedgeCommand(
          extra = dataWedgeEnumerateScanners,
          value = "",
          commandTag = "ENUMERATE_SCANNERS"
        )
        result.success(true)
      }

      "setDefaultProfile" -> {
        val profileName = call.argument<String>("profileName") ?: "MC930B_PROFILE"
        sendDataWedgeCommand(
          extra = dataWedgeSetDefaultProfile,
          value = profileName,
          commandTag = "SET_DEFAULT_PROFILE"
        )
        result.success(true)
      }

      "getConfig" -> {
        val profileName = call.argument<String>("profileName") ?: "MC930B_PROFILE"
        val pluginName = call.argument<String>("pluginName")
        val payload = Bundle().apply {
          putString("PROFILE_NAME", profileName)
          if (!pluginName.isNullOrBlank()) {
            putString("PLUGIN_NAME", pluginName)
          }
        }

        sendDataWedgeBundleCommand(
          extra = dataWedgeGetConfig,
          value = payload,
          commandTag = "GET_CONFIG"
        )
        result.success(true)
      }

      "sendCommand" -> {
        val command = call.argument<String>("command")
        if (command.isNullOrBlank()) {
          result.error("invalid_command", "command is required", null)
          return
        }

        val value = call.argument<Any>("value")
        val commandTag = call.argument<String>("commandTag") ?: command
        val requestResult = call.argument<Boolean>("requestResult") ?: true

        sendDataWedgeCommand(
          extra = command,
          value = value,
          commandTag = commandTag,
          requestResult = requestResult
        )
        result.success(true)
      }

      "sendCommandBundle" -> {
        val command = call.argument<String>("command")
        if (command.isNullOrBlank()) {
          result.error("invalid_command", "command is required", null)
          return
        }

        val value = call.argument<HashMap<String, Any?>>("value") ?: hashMapOf()
        val commandTag = call.argument<String>("commandTag") ?: command
        val requestResult = call.argument<Boolean>("requestResult") ?: true

        sendDataWedgeBundleCommand(
          extra = command,
          value = mapToBundle(value),
          commandTag = commandTag,
          requestResult = requestResult
        )
        result.success(true)
      }

      "sendIntent" -> {
        val extras = call.argument<HashMap<String, Any?>>("extras") ?: hashMapOf()
        val action = call.argument<String>("action") ?: dataWedgeAction
        val targetPackage = call.argument<String>("targetPackage")
        val commandTag = call.argument<String>("commandTag") ?: "CUSTOM_INTENT"
        val requestResult = call.argument<Boolean>("requestResult") ?: true
        val orderedBroadcast = call.argument<Boolean>("orderedBroadcast") ?: false
        val includeApplicationPackage =
          call.argument<Boolean>("includeApplicationPackage") ?: false

        sendIntentWithExtras(
          action = action,
          extras = extras,
          targetPackage = targetPackage,
          commandTag = commandTag,
          requestResult = requestResult,
          orderedBroadcast = orderedBroadcast,
          includeApplicationPackage = includeApplicationPackage
        )
        result.success(true)
      }

      else -> result.notImplemented()
    }
  }

  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    eventSink = events
    registerScanReceiver()
  }

  override fun onCancel(arguments: Any?) {
    eventSink = null
    unregisterScanReceiver()
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    unregisterScanReceiver()
    methodChannel.setMethodCallHandler(null)
    eventChannel.setStreamHandler(null)
  }

  private fun isDataWedgeAvailable(): Boolean {
    return try {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
        appContext.packageManager.getPackageInfo(
          "com.symbol.datawedge",
          PackageManager.PackageInfoFlags.of(0)
        )
      } else {
        @Suppress("DEPRECATION")
        appContext.packageManager.getPackageInfo("com.symbol.datawedge", 0)
      }
      true
    } catch (_: Exception) {
      false
    }
  }

  private fun configureDataWedgeProfile(profileName: String) {
    sendDataWedgeCommand(
      extra = dataWedgeCreateProfile,
      value = profileName,
      commandTag = "CREATE_PROFILE"
    )

    sendSetConfig(
      profileName = profileName,
      pluginName = "BARCODE",
      paramList = Bundle().apply {
        putString("scanner_selection", "auto")
        putString("scanner_selection_by_identifier", "AUTO")
        putString("scanner_input_enabled", "true")
      }
    )

    sendSetConfig(
      profileName = profileName,
      pluginName = "INTENT",
      paramList = Bundle().apply {
        putString("intent_output_enabled", "true")
        putString("intent_action", scanIntentAction)
        putString("intent_category", Intent.CATEGORY_DEFAULT)
        putString("intent_delivery", "2")
      }
    )

    sendSetConfig(
      profileName = profileName,
      pluginName = "KEYSTROKE",
      paramList = Bundle().apply {
        putString("keystroke_output_enabled", "false")
      }
    )

    registerForNotifications()
    sendDataWedgeCommand(
      extra = dataWedgeGetActiveProfile,
      value = "",
      commandTag = "GET_ACTIVE_PROFILE"
    )
  }

  private fun registerForNotification(type: String) {
    val payload = Bundle().apply {
      putString(dataWedgeApplicationName, appContext.packageName)
      putString(dataWedgeNotificationType, type)
    }

    sendDataWedgeBundleCommand(
      extra = dataWedgeRegisterForNotification,
      value = payload,
      commandTag = "REGISTER_NOTIFICATION_$type"
    )
  }

  private fun unregisterForNotification(type: String) {
    val payload = Bundle().apply {
      putString(dataWedgeApplicationName, appContext.packageName)
      putString(dataWedgeNotificationType, type)
    }

    sendDataWedgeBundleCommand(
      extra = dataWedgeUnregisterForNotification,
      value = payload,
      commandTag = "UNREGISTER_NOTIFICATION_$type"
    )
  }

  private fun sendSetConfig(
    profileName: String,
    pluginName: String,
    paramList: Bundle
  ) {
    val profileConfig = Bundle().apply {
      putString("PROFILE_NAME", profileName)
      putString("PROFILE_ENABLED", "true")
      putString("CONFIG_MODE", "UPDATE")
      putParcelableArray(
        "APP_LIST",
        arrayOf(
          Bundle().apply {
            putString("PACKAGE_NAME", appContext.packageName)
            putStringArray("ACTIVITY_LIST", arrayOf("*"))
          }
        )
      )
      putBundle(
        "PLUGIN_CONFIG",
        Bundle().apply {
          putString("PLUGIN_NAME", pluginName)
          putString("RESET_CONFIG", "true")
          putBundle("PARAM_LIST", paramList)
        }
      )
    }

    val setConfigIntent = Intent().apply {
      action = dataWedgeAction
      putExtra(dataWedgeSetConfig, profileConfig)
      putExtra(dataWedgeSendResult, dataWedgeSendResultMode)
      putExtra(dataWedgeCommandIdentifier, nextCommandId("SET_CONFIG_$pluginName"))
    }
    appContext.sendBroadcast(setConfigIntent)
    emitDebug("Sent SET_CONFIG for plugin $pluginName")
  }

  private fun sendDataWedgeCommand(
    extra: String,
    value: Any?,
    commandTag: String = extra,
    requestResult: Boolean = true
  ) {
    val intent = Intent().apply {
      action = dataWedgeAction
      putIntentExtra(this, extra, value)
      if (requestResult) {
        putExtra(dataWedgeSendResult, dataWedgeSendResultMode)
        putExtra(dataWedgeCommandIdentifier, nextCommandId(commandTag))
      }
    }
    appContext.sendBroadcast(intent)
    emitDebug("Sent command $commandTag")
  }

  private fun sendDataWedgeBundleCommand(
    extra: String,
    value: Bundle,
    commandTag: String,
    requestResult: Boolean = true
  ) {
    val intent = Intent().apply {
      action = dataWedgeAction
      putExtra(extra, value)
      if (requestResult) {
        putExtra(dataWedgeSendResult, dataWedgeSendResultMode)
        putExtra(dataWedgeCommandIdentifier, nextCommandId(commandTag))
      }
    }
    appContext.sendBroadcast(intent)
    emitDebug("Sent bundle command $commandTag")
  }

  private fun sendIntentWithExtras(
    action: String,
    extras: Map<String, Any?>,
    targetPackage: String?,
    commandTag: String,
    requestResult: Boolean,
    orderedBroadcast: Boolean,
    includeApplicationPackage: Boolean
  ) {
    val intent = Intent().apply {
      this.action = action

      if (!targetPackage.isNullOrBlank()) {
        setPackage(targetPackage)
      }

      if (includeApplicationPackage) {
        putExtra("APPLICATION_PACKAGE", appContext.packageName)
      }

      extras.forEach { (key, value) ->
        putIntentExtra(this, key, value)
      }

      if (requestResult) {
        putExtra(dataWedgeSendResult, dataWedgeSendResultMode)
        putExtra(dataWedgeCommandIdentifier, nextCommandId(commandTag))
      }
    }

    if (orderedBroadcast) {
      appContext.sendOrderedBroadcast(intent, null)
    } else {
      appContext.sendBroadcast(intent)
    }

    emitDebug("Sent custom intent $commandTag")
  }

  private fun registerForNotifications() {
    listOf("SCANNER_STATUS", "PROFILE_SWITCH", "CONFIGURATION_UPDATE", "WORKFLOW_STATUS")
      .forEach { type ->
      registerForNotification(type)
    }
  }

  private fun handleScanIntent(intent: Intent) {
    val data = (
      intent.getStringExtra(scanDataKey)
        ?: intent.getStringExtra(legacyScanDataKey)
        ?: intent.extras?.get(scanDataKey)?.toString()
        ?: intent.extras?.get(legacyScanDataKey)?.toString()
      ).orEmpty().trim()

    if (data.isEmpty()) {
      emitDebug("Scan intent received with empty payload")
      return
    }

    val labelType = intent.getStringExtra(scanLabelTypeKey).orEmpty()
    val payload = mutableMapOf<String, Any?>(
      "type" to "scan",
      "data" to data,
      "labelType" to labelType
    )

    val extras = bundleToMap(intent.extras)
    if (extras.isNotEmpty()) {
      payload["extras"] = extras
    }

    eventSink?.success(payload)
  }

  private fun handleResultIntent(intent: Intent) {
    val payload = bundleToMap(intent.extras).toMutableMap()
    payload["type"] = "commandResult"
    payload["command"] = intent.getStringExtra(dataWedgeCommand).orEmpty()
    payload["result"] = intent.getStringExtra(dataWedgeResult).orEmpty()
    payload["commandId"] = intent.getStringExtra(dataWedgeCommandIdentifier).orEmpty()
    payload["resultInfo"] = bundleToMap(intent.getBundleExtra(dataWedgeResultInfo))
    payload["resultInfoText"] = bundleToString(intent.getBundleExtra(dataWedgeResultInfo))

    eventSink?.success(payload)
  }

  private fun handleNotificationIntent(intent: Intent) {
    val notification = intent.getBundleExtra(dataWedgeNotification)
    val payload = bundleToMap(notification).toMutableMap()
    payload["type"] = "notification"
    payload["notificationType"] = notification?.getString(dataWedgeNotificationType).orEmpty()
    payload["status"] = notification?.getString(dataWedgeNotificationStatus).orEmpty()
    payload["profileName"] = notification?.getString(dataWedgeProfileName).orEmpty()
    payload["raw"] = bundleToString(notification)

    eventSink?.success(payload)
  }

  private fun bundleToString(bundle: Bundle?): String {
    if (bundle == null || bundle.isEmpty) {
      return ""
    }

    return bundle.keySet().joinToString(", ") { key ->
      "$key=${normalizeBundleValue(bundle.get(key))}"
    }
  }

  private fun bundleToMap(bundle: Bundle?): Map<String, Any?> {
    if (bundle == null || bundle.isEmpty) {
      return emptyMap()
    }

    val map = mutableMapOf<String, Any?>()
    bundle.keySet().forEach { key ->
      map[key] = normalizeBundleValue(bundle.get(key))
    }
    return map
  }

  private fun normalizeBundleValue(value: Any?): Any? {
    return when (value) {
      null -> null
      is Bundle -> bundleToMap(value)
      is IntArray -> value.toList()
      is LongArray -> value.toList()
      is DoubleArray -> value.toList()
      is FloatArray -> value.toList()
      is BooleanArray -> value.toList()
      is Array<*> -> value.map { normalizeBundleValue(it) }
      is ArrayList<*> -> value.map { normalizeBundleValue(it) }
      is List<*> -> value.map { normalizeBundleValue(it) }
      is Parcelable -> value.toString()
      else -> value
    }
  }

  private fun nextCommandId(prefix: String): String {
    commandSequence += 1
    return "$prefix-${System.currentTimeMillis()}-$commandSequence"
  }

  private fun emitDebug(message: String) {
    eventSink?.success(
      mapOf(
        "type" to "debug",
        "message" to message
      )
    )
  }

  private fun registerScanReceiver() {
    if (receiverRegistered) {
      return
    }

    val filter = IntentFilter(scanIntentAction).apply {
      addCategory(Intent.CATEGORY_DEFAULT)
      addAction("com.basicintent.ACTION")  // secondary scan action
      addAction(dataWedgeResultAction)
      addAction(dataWedgeNotificationAction)
    }

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
      appContext.registerReceiver(scanReceiver, filter, Context.RECEIVER_EXPORTED)
    } else {
      @Suppress("UnspecifiedRegisterReceiverFlag")
      appContext.registerReceiver(scanReceiver, filter)
    }
    receiverRegistered = true
  }

  private fun unregisterScanReceiver() {
    if (!receiverRegistered) {
      return
    }

    try {
      appContext.unregisterReceiver(scanReceiver)
    } catch (_: IllegalArgumentException) {
    }

    receiverRegistered = false
  }

  private fun putIntentExtra(intent: Intent, key: String, value: Any?) {
    when (value) {
      null -> intent.putExtra(key, "")
      is String -> intent.putExtra(key, value)
      is Boolean -> intent.putExtra(key, value)
      is Int -> intent.putExtra(key, value)
      is Long -> intent.putExtra(key, value)
      is Double -> intent.putExtra(key, value)
      is Float -> intent.putExtra(key, value)
      is Bundle -> intent.putExtra(key, value)
      is IntArray -> intent.putExtra(key, value)
      is LongArray -> intent.putExtra(key, value)
      is DoubleArray -> intent.putExtra(key, value)
      is FloatArray -> intent.putExtra(key, value)
      is BooleanArray -> intent.putExtra(key, value)
      is Array<*> -> putIntentArrayExtra(intent, key, value)
      is List<*> -> putIntentListExtra(intent, key, value)
      is Map<*, *> -> intent.putExtra(key, mapToBundle(value))
      else -> intent.putExtra(key, value.toString())
    }
  }

  private fun putIntentArrayExtra(intent: Intent, key: String, values: Array<*>) {
    if (values.all { it is String }) {
      intent.putExtra(key, values.filterIsInstance<String>().toTypedArray())
      return
    }

    if (values.all { it is Int }) {
      intent.putExtra(key, values.filterIsInstance<Int>().toIntArray())
      return
    }

    if (values.all { it is Long }) {
      intent.putExtra(key, values.filterIsInstance<Long>().toLongArray())
      return
    }

    if (values.all { it is Double }) {
      intent.putExtra(key, values.filterIsInstance<Double>().toDoubleArray())
      return
    }

    if (values.all { it is Float }) {
      intent.putExtra(key, values.filterIsInstance<Float>().toFloatArray())
      return
    }

    if (values.all { it is Boolean }) {
      val boolArray = BooleanArray(values.size) { index -> values[index] as Boolean }
      intent.putExtra(key, boolArray)
      return
    }

    if (values.all { it is Bundle }) {
      intent.putExtra(key, values.filterIsInstance<Bundle>().toTypedArray())
      return
    }

    if (values.all { it is Parcelable }) {
      intent.putExtra(key, values.filterIsInstance<Parcelable>().toTypedArray())
      return
    }

    intent.putExtra(key, values.map { it?.toString() ?: "" }.toTypedArray())
  }

  private fun putIntentListExtra(intent: Intent, key: String, list: List<*>) {
    if (list.isEmpty()) {
      intent.putExtra(key, arrayOf<String>())
      return
    }

    if (list.all { it is Map<*, *> }) {
      val bundles = ArrayList<Bundle>()
      list.forEach { item ->
        bundles.add(mapToBundle(item as Map<*, *>))
      }
      intent.putParcelableArrayListExtra(key, bundles)
      return
    }

    if (list.all { it is Bundle }) {
      intent.putParcelableArrayListExtra(key, ArrayList(list.filterIsInstance<Bundle>()))
      return
    }

    if (list.all { it is String }) {
      intent.putExtra(key, list.filterIsInstance<String>().toTypedArray())
      return
    }

    if (list.all { it is Int }) {
      intent.putExtra(key, list.filterIsInstance<Int>().toIntArray())
      return
    }

    if (list.all { it is Long }) {
      intent.putExtra(key, list.filterIsInstance<Long>().toLongArray())
      return
    }

    if (list.all { it is Double }) {
      intent.putExtra(key, list.filterIsInstance<Double>().toDoubleArray())
      return
    }

    if (list.all { it is Float }) {
      intent.putExtra(key, list.filterIsInstance<Float>().toFloatArray())
      return
    }

    if (list.all { it is Boolean }) {
      val boolArray = BooleanArray(list.size) { index -> list[index] as Boolean }
      intent.putExtra(key, boolArray)
      return
    }

    intent.putExtra(key, list.map { it?.toString() ?: "" }.toTypedArray())
  }

  private fun mapToBundle(value: Map<*, *>): Bundle {
    val bundle = Bundle()
    for ((k, v) in value) {
      val key = k as? String ?: continue
      putBundleValue(bundle, key, v)
    }
    return bundle
  }

  private fun putBundleValue(bundle: Bundle, key: String, value: Any?) {
    when (value) {
      null -> bundle.putString(key, null)
      is String -> bundle.putString(key, value)
      is Boolean -> bundle.putBoolean(key, value)
      is Int -> bundle.putInt(key, value)
      is Long -> bundle.putLong(key, value)
      is Double -> bundle.putDouble(key, value)
      is Float -> bundle.putFloat(key, value)
      is Bundle -> bundle.putBundle(key, value)
      is IntArray -> bundle.putIntArray(key, value)
      is LongArray -> bundle.putLongArray(key, value)
      is DoubleArray -> bundle.putDoubleArray(key, value)
      is FloatArray -> bundle.putFloatArray(key, value)
      is BooleanArray -> bundle.putBooleanArray(key, value)
      is Array<*> -> putBundleArrayValue(bundle, key, value)
      is Map<*, *> -> bundle.putBundle(key, mapToBundle(value))
      is List<*> -> putBundleListValue(bundle, key, value)
      else -> bundle.putString(key, value.toString())
    }
  }

  private fun putBundleArrayValue(bundle: Bundle, key: String, values: Array<*>) {
    if (values.all { it is String }) {
      bundle.putStringArray(key, values.filterIsInstance<String>().toTypedArray())
      return
    }

    if (values.all { it is Int }) {
      bundle.putIntArray(key, values.filterIsInstance<Int>().toIntArray())
      return
    }

    if (values.all { it is Long }) {
      bundle.putLongArray(key, values.filterIsInstance<Long>().toLongArray())
      return
    }

    if (values.all { it is Double }) {
      bundle.putDoubleArray(key, values.filterIsInstance<Double>().toDoubleArray())
      return
    }

    if (values.all { it is Float }) {
      bundle.putFloatArray(key, values.filterIsInstance<Float>().toFloatArray())
      return
    }

    if (values.all { it is Boolean }) {
      val boolArray = BooleanArray(values.size) { index -> values[index] as Boolean }
      bundle.putBooleanArray(key, boolArray)
      return
    }

    if (values.all { it is Bundle }) {
      bundle.putParcelableArray(key, values.filterIsInstance<Bundle>().toTypedArray())
      return
    }

    bundle.putStringArray(key, values.map { it?.toString() ?: "" }.toTypedArray())
  }

  private fun putBundleListValue(bundle: Bundle, key: String, list: List<*>) {
    if (list.isEmpty()) {
      bundle.putStringArrayList(key, arrayListOf())
      return
    }

    if (list.all { it is Map<*, *> }) {
      val bundles = ArrayList<Bundle>()
      list.forEach { item ->
        bundles.add(mapToBundle(item as Map<*, *>))
      }
      bundle.putParcelableArrayList(key, bundles)
      return
    }

    if (list.all { it is Bundle }) {
      bundle.putParcelableArrayList(key, ArrayList(list.filterIsInstance<Bundle>()))
      return
    }

    if (list.all { it is String }) {
      bundle.putStringArrayList(key, ArrayList(list.filterIsInstance<String>()))
      return
    }

    if (list.all { it is Int }) {
      bundle.putIntegerArrayList(key, ArrayList(list.filterIsInstance<Int>()))
      return
    }

    if (list.all { it is Long }) {
      bundle.putLongArray(key, list.filterIsInstance<Long>().toLongArray())
      return
    }

    if (list.all { it is Double }) {
      bundle.putDoubleArray(key, list.filterIsInstance<Double>().toDoubleArray())
      return
    }

    if (list.all { it is Float }) {
      bundle.putFloatArray(key, list.filterIsInstance<Float>().toFloatArray())
      return
    }

    if (list.all { it is Boolean }) {
      val boolArray = BooleanArray(list.size) { index -> list[index] as Boolean }
      bundle.putBooleanArray(key, boolArray)
      return
    }

    bundle.putStringArrayList(
      key,
      ArrayList(list.map { it?.toString() ?: "" })
    )
  }
}
