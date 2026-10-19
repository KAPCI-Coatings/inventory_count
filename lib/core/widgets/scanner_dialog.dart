import 'dart:async';
import 'package:flutter/material.dart';
import '../di/di.dart';
import '../services/scanner_service.dart';
import '../services/scanner_popup_guard.dart';

/// All app dialogs use this entry point so even closing animations block scans.
Future<T?> showScannerDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = false,
}) {
  final scanner = instance.isRegistered<ScannerService>()
      ? instance<ScannerService>()
      : null;
  final route = DialogRoute<T>(
    context: context,
    builder: builder,
    barrierDismissible: barrierDismissible,
    themes: InheritedTheme.capture(
      from: context,
      to: Navigator.of(context, rootNavigator: true).context,
    ),
  );
  ScannerPopupGuard.hold(scanner);
  try {
    final result = Navigator.of(context, rootNavigator: true).push(route);
    unawaited(route.completed.then((_) => ScannerPopupGuard.release(scanner)));
    return result;
  } catch (_) {
    ScannerPopupGuard.release(scanner);
    rethrow;
  }
}
