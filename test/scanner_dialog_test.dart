import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_count_flutter_app/core/di/di.dart';
import 'package:inventory_count_flutter_app/core/services/scanner_service.dart';
import 'package:inventory_count_flutter_app/core/services/scanner_popup_guard.dart';
import 'package:inventory_count_flutter_app/core/widgets/scanner_dialog.dart';
import 'package:inventory_count_flutter_app/core/services/zebra_scanner_service.dart';

class PopupScanner extends Fake implements ScannerService {
  final calls = <String>[];
  @override
  Future<void> disableScanner() async {
    calls.add('disable');
  }

  @override
  Future<void> suspendScanner() async {
    calls.add('suspend');
  }

  @override
  Future<void> resumeScanner() async {
    calls.add('resume');
  }

  @override
  Future<void> enableScanner() async {
    calls.add('enable');
  }
}

void main() {
  test('Zebra enable, resume and soft triggers cannot bypass a popup', () async {
    final scanner = ZebraScannerService(androidPackageName: 'test');
    ScannerPopupGuard.hold(null);
    try {
      // Normally these throw before initialize; with a dialog they must return
      // without reaching DataWedge at all.
      await scanner.enableScanner();
      await scanner.resumeScanner();
      await scanner.startSoftScan();
      await scanner.toggleSoftScan();
      scanner.didChangeAppLifecycleState(AppLifecycleState.resumed);
    } finally {
      ScannerPopupGuard.release(null);
    }
  });
  testWidgets(
    'nested popups disable until the last closing animation finishes',
    (tester) async {
      final scanner = PopupScanner();
      instance.registerSingleton<ScannerService>(scanner);
      addTearDown(() => instance.unregister<ScannerService>());
      late BuildContext context;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (c) {
              context = c;
              return const Scaffold();
            },
          ),
        ),
      );
      unawaited(
        showScannerDialog<void>(
          context: context,
          builder: (_) => const AlertDialog(content: Text('first')),
        ),
      );
      await tester.pumpAndSettle();
      expect(ScannerPopupGuard.isOpen, true);
      expect(scanner.calls, ['disable', 'suspend']);
      unawaited(
        showScannerDialog<void>(
          context: context,
          builder: (_) => const AlertDialog(content: Text('second')),
        ),
      );
      await tester.pumpAndSettle();
      Navigator.of(context).pop();
      await tester.pumpAndSettle();
      expect(ScannerPopupGuard.isOpen, true);
      expect(scanner.calls.where((c) => c == 'enable'), isEmpty);
      Navigator.of(context).pop();
      await tester.pump();
      expect(ScannerPopupGuard.isOpen, true);
      await tester.pumpAndSettle();
      expect(ScannerPopupGuard.isOpen, false);
      expect(scanner.calls, ['disable', 'suspend', 'resume', 'enable']);
    },
  );
}
