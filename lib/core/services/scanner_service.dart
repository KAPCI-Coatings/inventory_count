import 'dart:async';

/// Represents the result of a single barcode scan.
class ScanResult {
  const ScanResult({
    required this.data,
    required this.labelType,
    this.timestamp,
  });

  /// The raw barcode/RFID data string.
  final String data;

  /// The symbology / label type (e.g. CODE128, QR_CODE, EAN13, …).
  final String labelType;

  /// The UTC timestamp of when the scan was received by the service.
  final DateTime? timestamp;

  @override
  String toString() => 'ScanResult(data: $data, labelType: $labelType)';
}

/// Possible states the hardware scanner can be in.
enum ScannerStatus {
  /// Scanner is ready and idle.
  idle,

  /// Scanner is actively scanning.
  scanning,

  /// Scanner has been disabled by the app.
  disabled,

  /// Scanner is suspended (temporarily paused).
  suspended,

  /// DataWedge / scanner service is not available on this device.
  unavailable,

  /// Unknown / not yet determined.
  unknown,
}

/// Abstract contract for any barcode-scanner integration.
///
/// The rest of the app only depends on this interface.
/// The concrete implementation (e.g. [ZebraScannerService]) is swapped
/// via dependency injection, so if the underlying package ever changes you only
/// update the implementation — zero app-level changes required.
///
/// Usage:
/// ```dart
/// final ScannerService scanner = instance<ScannerService>();
/// await scanner.initialize();
///
/// scanner.onScan.listen((result) {
///   print('Scanned: ${result.data}');
/// });
///
/// await scanner.enableScanner();
/// ```
abstract class ScannerService {
  // ── Lifecycle ────────────────────────────────────────────────────────────

  /// Initialises the scanner service.
  ///
  /// Must be called once before any other method.
  /// Throws [ScannerUnavailableException] if the service is not available
  /// on this device.
  Future<void> initialize();

  /// Releases all resources held by the service.
  ///
  /// Call this when the app or the relevant screen is disposed.
  Future<void> dispose();

  // ── Availability ─────────────────────────────────────────────────────────

  /// Returns `true` if the scanner service is available on this device.
  Future<bool> isAvailable();

  // ── Scan stream ──────────────────────────────────────────────────────────

  /// A broadcast stream that emits a [ScanResult] each time a barcode is read.
  Stream<ScanResult> get onScan;

  /// A broadcast stream that emits the current [ScannerStatus] whenever it changes.
  Stream<ScannerStatus> get onStatusChange;

  // ── Scanner control ──────────────────────────────────────────────────────

  /// Enables the scanner so it can receive hardware-trigger events.
  Future<void> enableScanner();

  /// Disables the scanner — it will not respond to the trigger button.
  Future<void> disableScanner();

  /// Suspends the scanner temporarily (keeps session alive).
  Future<void> suspendScanner();

  /// Resumes a suspended scanner.
  Future<void> resumeScanner();

  // ── Soft trigger ─────────────────────────────────────────────────────────

  /// Programmatically starts a scan (like pressing the physical trigger).
  Future<void> startSoftScan();

  /// Stops an ongoing programmatic scan.
  Future<void> stopSoftScan();

  /// Toggles the programmatic scan on/off.
  Future<void> toggleSoftScan();

  // ── Profile management ───────────────────────────────────────────────────

  /// Switches to an existing named profile.
  Future<void> switchToProfile(String profileName);

  /// Returns the name of the currently active profile.
  ///
  /// The value is delivered asynchronously via [onStatusChange] /
  /// the underlying event stream on some implementations.
  Future<void> getActiveProfile();

  // ── DataWedge service ────────────────────────────────────────────────────

  /// Enables or disables the DataWedge service entirely.
  Future<void> setDataWedgeEnabled({required bool enabled});

  /// Queries the current scanner status.
  ///
  /// Result is emitted on the underlying event/status stream.
  Future<void> getScannerStatus();
}

// ── Exceptions ────────────────────────────────────────────────────────────────

/// Thrown when the scanner service is not available on the current device.
class ScannerUnavailableException implements Exception {
  const ScannerUnavailableException([this.message = 'Scanner service is not available on this device.']);
  final String message;

  @override
  String toString() => 'ScannerUnavailableException: $message';
}

/// Thrown when a scanner operation fails.
class ScannerOperationException implements Exception {
  const ScannerOperationException(this.message, {this.cause});
  final String message;
  final Object? cause;

  @override
  String toString() => 'ScannerOperationException: $message${cause != null ? ' (cause: $cause)' : ''}';
}
