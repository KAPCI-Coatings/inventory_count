import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_count_flutter_app/l10n/app_localizations.dart';
import 'package:inventory_count_flutter_app/domain/uescases/process_barcode_usecase.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/barcode/barcode_bloc.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/barcode/barcode_event.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/barcode/barcode_state.dart';
import 'package:inventory_count_flutter_app/presentation/widgets/barcode/barcode_status_section.dart';
import 'barcode_upload_test.dart' show EmptyRepository, Api, Scanner, Settings;

void main() {
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

  test('default pallet mode rejects boxes before saving or counting', () async {
    final next = bloc.stream.first;
    bloc.add(BarcodeScanned('12345600000000010001', ''));
    final state = await next;
    expect(state.status, BarcodeStatus.error);
    expect(state.centeredErrorMessage, 'error_scan_pallets_only');
    expect(repo.items, isEmpty);
    expect(state.boxCount, 0);
    expect(state.palletCount, 0);
    expect(state.dailyScanCount, 0);
  });

  testWidgets(
    'radio selection gates scans and retains counts across switches',
    (tester) async {
      Future<void> scan(String barcode) async {
        await tester.runAsync(() async {
          final next = bloc.stream.first;
          bloc.add(BarcodeScanned(barcode, ''));
          await next;
        });
        await tester.pumpAndSettle();
      }

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider.value(
            value: bloc,
            child: const Scaffold(body: BarcodeStatusSection()),
          ),
        ),
      );
      expect(find.text('Pallets'), findsOneWidget);
      expect(find.text('Boxes'), findsOneWidget);
      await scan('P1234560000000001Z025');
      expect(bloc.state.palletCount, 1);
      expect(bloc.state.boxCount, 25);

      await tester.tap(find.text('Boxes'));
      await tester.pumpAndSettle();
      await scan('12345600000000010001');
      expect(bloc.state.boxCount, 26);
      await scan('P1234560000000002Z025');
      expect(bloc.state.centeredErrorMessage, 'error_scan_boxes_only');
      expect(repo.items, hasLength(2));
      expect(bloc.state.palletCount, 1);
      expect(bloc.state.boxCount, 26);
      expect(bloc.state.dailyScanCount, 2);

      // A rejected scan must not reset the selected mode.
      await scan('12345600000000010002');
      expect(bloc.state.boxCount, 27);
      await tester.tap(find.text('Pallets'));
      await tester.pumpAndSettle();
      await scan('12345600000000010003');
      expect(bloc.state.centeredErrorMessage, 'error_scan_pallets_only');
      expect(repo.items, hasLength(3));
      expect(bloc.state.boxCount, 27);
    },
  );
}
