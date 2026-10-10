import 'dart:async';
import 'package:inventory_count_flutter_app/presentation/view_models/barcode/barcode_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_count_flutter_app/l10n/app_localizations.dart';
import 'package:inventory_count_flutter_app/domain/uescases/process_barcode_usecase.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/auth/auth_bloc.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/auth/auth_state.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/barcode/barcode_bloc.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/barcode/barcode_state.dart';
import 'package:inventory_count_flutter_app/presentation/widgets/barcode/barcode_actions_section.dart';
import 'package:inventory_count_flutter_app/presentation/widgets/barcode/barcode_status_section.dart';
import 'barcode_upload_test.dart' show Api, Scanner, Settings;
import 'pallet_numbering_test.dart' show ControlledRepository;

class TestAuthBloc extends Fake implements AuthBloc {
  final String role;
  TestAuthBloc(this.role);
  @override
  AuthState get state => AuthState(selectedRole: role);
  @override
  Stream<AuthState> get stream => const Stream.empty();
}

void main() {
  for (final language in ['en', 'ar']) {
    testWidgets(
      '$language button beside Search selects Boxes and advances number',
      (tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final repo = ControlledRepository();
        final api = Api();
        final bloc = BarcodeBloc(
          Scanner(),
          ProcessBarcodeUseCase(repo),
          api,
          Settings(),
          repo,
        );
        addTearDown(bloc.close);
        addTearDown(api.dispose);
        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>.value(value: TestAuthBloc('Admin')),
              BlocProvider<BarcodeBloc>.value(value: bloc),
            ],
            child: MaterialApp(
              locale: Locale(language),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const Scaffold(
                body: Column(
                  children: [
                    Expanded(
                      child: BarcodeStatusSection(
                        compact: true,
                        fillAvailableHeight: true,
                      ),
                    ),
                    BarcodeActionsSection(),
                  ],
                ),
              ),
            ),
          ),
        );
        final label = language == 'ar' ? 'اضافه بالته جديده' : 'Add New Pallet';
        final add = find.text(label);
        expect(add, findsOneWidget);
        final search = find.text('بحث');
        expect(
          tester.getCenter(add).dy,
          closeTo(tester.getCenter(search).dy, 2),
        );
        await tester.tap(add);
        await tester.pumpAndSettle();
        expect(bloc.state.currentExportPalletNo, 0);
        await tester.tap(find.text(language == 'ar' ? 'لا' : 'No'));
        await tester.pumpAndSettle();
        expect(bloc.state.currentExportPalletNo, 0);
        expect(bloc.state.scanType, ScanType.pallet);
        await tester.tap(add);
        await tester.pumpAndSettle();
        bloc.add(BarcodeScanned('P1234560000000001Z025', ''));
        await tester.pumpAndSettle();
        expect(repo.items, isEmpty);
        await tester.tap(find.text(language == 'ar' ? 'نعم' : 'Yes'));
        await tester.pumpAndSettle();
        expect(bloc.state.scanType, ScanType.box);
        expect(bloc.state.currentExportPalletNo, 1);
        expect(
          tester
              .widget<RadioGroup<ScanType>>(find.byType(RadioGroup<ScanType>))
              .groupValue,
          ScanType.box,
        );
        await tester.tap(add);
        await tester.pumpAndSettle();
        await tester.tap(find.text(language == 'ar' ? 'نعم' : 'Yes'));
        await tester.pumpAndSettle();
        expect(bloc.state.currentExportPalletNo, 1);
        expect(bloc.state.centeredErrorMessage, 'error_empty_pallet');
        bloc.add(BarcodeScanned('12345600000000010001', ''));
        await tester.pumpAndSettle();
        repo.gate = Completer<void>();
        await tester.tap(add);
        await tester.pumpAndSettle();
        await tester.tap(find.text(language == 'ar' ? 'نعم' : 'Yes'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        final button = tester.widget<ElevatedButton>(
          find.ancestor(of: add, matching: find.byType(ElevatedButton)),
        );
        expect(button.onPressed, isNull);
        repo.gate!.complete();
        await tester.pumpAndSettle();
        expect(bloc.state.currentExportPalletNo, 2);
        expect(repo.items, hasLength(1));
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('restricted role retains Search Export Exit without new button', (
    tester,
  ) async {
    final api = Api();
    final repo = ControlledRepository();
    final bloc = BarcodeBloc(
      Scanner(),
      ProcessBarcodeUseCase(repo),
      api,
      Settings(),
      repo,
    );
    addTearDown(bloc.close);
    addTearDown(api.dispose);
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: TestAuthBloc('User')),
          BlocProvider<BarcodeBloc>.value(value: bloc),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: BarcodeActionsSection()),
        ),
      ),
    );
    expect(find.text('Add New Pallet'), findsNothing);
    expect(find.text('بحث'), findsOneWidget);
    expect(find.text('حفظ كملف'), findsOneWidget);
    expect(find.text('خروج'), findsOneWidget);
  });
}
