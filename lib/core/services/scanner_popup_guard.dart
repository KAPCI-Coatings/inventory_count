import 'package:flutter/foundation.dart';
import 'scanner_service.dart';

/// Keeps scanner suppression active across overlapping dialog transitions.
class ScannerPopupGuard {
  static int _depth = 0;
  static Future<void> _operations = Future<void>.value();
  static bool get isOpen => _depth > 0;

  static void hold(ScannerService? scanner) {
    _depth++;
    if (_depth != 1 || scanner == null) return;
    _operations = _operations.then((_) async {
      await _attempt(scanner.disableScanner);
      await _attempt(scanner.suspendScanner);
    });
  }

  static void release(ScannerService? scanner) {
    if (_depth == 0) return;
    _depth--;
    if (isOpen || scanner == null) return;
    _operations = _operations.then((_) async {
      if (isOpen) return;
      await _attempt(scanner.resumeScanner);
      if (!isOpen) await _attempt(scanner.enableScanner);
    });
  }

  static Future<void> _attempt(Future<void> Function() operation) async {
    try {
      await operation();
    } catch (error) {
      // Software scan guards remain active even if the device is unavailable.
      debugPrint('[ScannerPopupGuard] $error');
    }
  }
}
