import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_count_flutter_app/core/services/csv_export_service.dart';
import 'package:inventory_count_flutter_app/core/services/scanner_service.dart';
import 'package:inventory_count_flutter_app/domain/uescases/process_barcode_usecase.dart';
import 'package:inventory_count_flutter_app/l10n/app_localizations.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/barcode/barcode_bloc.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/barcode/barcode_event.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/barcode/barcode_state.dart';
import 'package:inventory_count_flutter_app/presentation/widgets/barcode/barcode_status_section.dart';
import 'barcode_upload_test.dart' show EmptyRepository, Api, Scanner, Settings;

void main() {
  group('export file name', () {
    test('morning time uses device, date and AM hour', () {
      expect(
        CsvExportService.inventoryFileName('053', DateTime(2026, 10, 18, 10, 30)),
        'Device(053)-18-10-2026-10-30AM',
      );
    });
    test('afternoon time uses 12-hour clock with PM', () {
      expect(
        CsvExportService.inventoryFileName('7', DateTime(2026, 1, 5, 15, 5)),
        'Device(7)-05-01-2026-03-05PM',
      );
    });
    test('file name never contains characters invalid on Android/Windows', () {
      final name =
          CsvExportService.inventoryFileName('053', DateTime(2026, 12, 31, 23, 59));
      expect(name, isNot(matches(RegExp(r'[:/\\*?"<>|]'))));
    });
    test('missing device id still produces a valid name', () {
      expect(
        CsvExportService.inventoryFileName('', DateTime(2026, 10, 18, 0, 0)),
        'Device()-18-10-2026-12-00AM',
      );
    });
  });

  group('switch Pallets -> Boxes popup', () {
    late EmptyRepository repo;
    late Api api;
    late BarcodeBloc bloc;

    setUp(() {
      repo = EmptyRepository();
      api = Api();
      bloc = BarcodeBloc(
        Scanner(),
        ProcessBarcodeUseCase(repo),
        api,
        Settings(),
        repo,
      );
    });
    tearDown(() async {
      await bloc.close();
      api.dispose();
    });

    Future<void> pump(WidgetTester tester, String lang) async {
      tester.view.physicalSize = const Size(480, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(lang),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider.value(
            value: bloc,
            child: const Scaffold(body: BarcodeStatusSection()),
          ),
        ),
      );
    }

    Future<void> scan(WidgetTester tester, String code) async {
      await tester.runAsync(() async {
        final next = bloc.stream.firstWhere(
          (s) => !s.isInventoryMutationInProgress,
        );
        bloc.add(BarcodeScanned(code, ''));
        await next;
      });
      await tester.pumpAndSettle();
    }

    Future<void> settleBloc(WidgetTester tester) async {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('no popup when nothing was scanned yet', (tester) async {
      await pump(tester, 'ar');
      await tester.tap(find.text('Boxes'));
      await settleBloc(tester);
      expect(find.text('الانتقال إلى الصناديق'), findsNothing);
      expect(bloc.state.scanType, ScanType.box);
    });

    for (final lang in ['ar', 'en']) {
      testWidgets('$lang: popup shows Arabic text and three bold buttons', (
        tester,
      ) async {
        await pump(tester, lang);
        await scan(tester, 'P1234560000000001Z025');
        expect(bloc.state.currentExportPalletNo, 1);
        await tester.tap(find.text('Boxes'));
        await tester.pumpAndSettle();

        expect(find.text('الانتقال إلى الصناديق'), findsOneWidget);
        for (final label in [
          'الغاء',
          'الاستمرار على الأخيرة',
          'انشاء بالتة جديدة',
        ]) {
          final text = tester.widget<Text>(find.text(label));
          expect(text.style?.fontWeight, FontWeight.bold, reason: label);
        }
        // Cancel and create sit in the same row with equal height.
        final cancel = tester.getRect(
          find.ancestor(
            of: find.text('الغاء'),
            matching: find.byType(OutlinedButton),
          ),
        );
        final create = tester.getRect(
          find.ancestor(
            of: find.text('انشاء بالتة جديدة'),
            matching: find.byType(ElevatedButton),
          ),
        );
        expect(cancel.top, closeTo(create.top, 0.5));
        expect(cancel.height, closeTo(create.height, 0.5));
        expect(create.width, greaterThan(cancel.width));
      });
    }

    testWidgets('cancel keeps Pallets mode and pallet number', (tester) async {
      await pump(tester, 'ar');
      await scan(tester, 'P1234560000000001Z025');
      await tester.tap(find.text('Boxes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('الغاء'));
      await settleBloc(tester);

      expect(find.text('الانتقال إلى الصناديق'), findsNothing);
      expect(bloc.state.scanType, ScanType.pallet);
      expect(bloc.state.currentExportPalletNo, 1);
    });

    testWidgets('keep last pallet switches to Boxes on same number', (
      tester,
    ) async {
      await pump(tester, 'ar');
      await scan(tester, 'P1234560000000001Z025');
      await tester.tap(find.text('Boxes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('الاستمرار على الأخيرة'));
      await settleBloc(tester);

      expect(bloc.state.scanType, ScanType.box);
      await scan(tester, '12345600000000010001');
      expect(repo.items.last.exportPalletNo, 1);
      expect(bloc.state.currentExportPalletNo, 1);
    });

    testWidgets('create new pallet switches to Boxes on next number', (
      tester,
    ) async {
      await pump(tester, 'ar');
      await scan(tester, 'P1234560000000001Z025');
      await tester.tap(find.text('Boxes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('انشاء بالتة جديدة'));
      await settleBloc(tester);

      expect(bloc.state.scanType, ScanType.box);
      expect(bloc.state.currentExportPalletNo, 2);
      await scan(tester, '12345600000000010001');
      expect(repo.items.last.exportPalletNo, 2);
    });

    testWidgets('popup still shows after a rejected duplicate pallet', (
      tester,
    ) async {
      await pump(tester, 'ar');
      await scan(tester, 'P1234560000000001Z025');
      await scan(tester, 'P1234560000000001Z025');
      expect(bloc.state.status, BarcodeStatus.warning);
      await tester.runAsync(() async {
        bloc.add(BarcodeDuplicateRejected());
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pumpAndSettle();
      await tester.tap(find.text('Boxes'));
      await tester.pumpAndSettle();
      expect(find.text('الانتقال إلى الصناديق'), findsOneWidget);
    });

    testWidgets('no popup after a box was already scanned', (tester) async {
      await pump(tester, 'ar');
      await scan(tester, 'P1234560000000001Z025');
      await tester.tap(find.text('Boxes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('الاستمرار على الأخيرة'));
      await settleBloc(tester);
      await scan(tester, '12345600000000010001');
      await tester.tap(find.text('Pallets'));
      await settleBloc(tester);
      await tester.tap(find.text('Boxes'));
      await settleBloc(tester);
      expect(find.text('الانتقال إلى الصناديق'), findsNothing);
      expect(bloc.state.scanType, ScanType.box);
    });
  });

  group('release fixes', () {
    late EmptyRepository repo;
    late Api api;
    late BarcodeBloc bloc;
    late StreamScanner scanner;

    setUp(() {
      repo = EmptyRepository();
      api = Api();
      scanner = StreamScanner();
      bloc = BarcodeBloc(
        scanner,
        ProcessBarcodeUseCase(repo),
        api,
        Settings(),
        repo,
      );
    });
    tearDown(() async {
      await bloc.close();
      api.dispose();
      await scanner.controller.close();
    });

    Future<void> scanDirect(String code) async {
      final next = bloc.stream.firstWhere(
        (s) => !s.isInventoryMutationInProgress,
      );
      bloc.add(BarcodeScanned(code, ''));
      await next;
    }

    test('hardware scans are ignored while barcode screen is hidden', () async {
      bloc.add(BarcodeScannerEnableRequested());
      await Future<void>.delayed(Duration.zero);

      bloc.isScreenVisible = false;
      scanner.controller.add(
        const ScanResult(data: 'P1234560000000001Z025', labelType: ''),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(repo.items, isEmpty);

      bloc.isScreenVisible = true;
      scanner.controller.add(
        const ScanResult(data: 'P1234560000000001Z025', labelType: ''),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(repo.items, hasLength(1));
    });

    test('full pallet after an empty reserved pallet reuses its number', () async {
      await scanDirect('P1234560000000001Z025'); // pallet 1
      bloc.add(BarcodeNewPalletRequested()); // reserves 2, still empty
      await bloc.stream.firstWhere((s) => s.currentExportPalletNo == 2);
      bloc.add(BarcodeScanTypeChanged(ScanType.pallet));
      await bloc.stream.firstWhere((s) => s.scanType == ScanType.pallet);

      await scanDirect('P1234560000000002Z025');
      expect(repo.items.last.exportPalletNo, 2);
      await scanDirect('P1234560000000003Z025');
      expect(repo.items.last.exportPalletNo, 3);
    });
  });
}

class StreamScanner extends Fake implements ScannerService {
  final controller = StreamController<ScanResult>.broadcast();
  @override
  Stream<ScanResult> get onScan => controller.stream;
  @override
  Future<void> enableScanner() async {}
  @override
  Future<void> disableScanner() async {}
}
