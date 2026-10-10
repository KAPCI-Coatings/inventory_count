import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_count_flutter_app/core/services/scanner_service.dart';
import 'package:inventory_count_flutter_app/core/widgets/error_popup.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/barcode/barcode_event.dart';
import 'package:inventory_count_flutter_app/l10n/app_localizations.dart';
import 'package:inventory_count_flutter_app/domain/uescases/process_barcode_usecase.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/auth/auth_bloc.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/auth/auth_state.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/barcode/barcode_bloc.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/barcode/barcode_state.dart';
import 'package:inventory_count_flutter_app/presentation/views/barcode_screen.dart';
import 'package:inventory_count_flutter_app/presentation/widgets/barcode/barcode_actions_section.dart';
import 'package:inventory_count_flutter_app/presentation/widgets/barcode/barcode_status_section.dart';
import 'barcode_upload_test.dart' show EmptyRepository, Api, Scanner, Settings;

class _AuthBloc extends Fake implements AuthBloc {
  @override
  AuthState get state => const AuthState(selectedRole: 'admin');
  @override
  Stream<AuthState> get stream => const Stream.empty();
}

class _Scanner extends Scanner {
  @override
  Stream<ScanResult> get onScan => const Stream.empty();
}

void main() {
  testWidgets('empty pallet notice blocks scans until dismissed', (
    tester,
  ) async {
    final repo = EmptyRepository();
    final api = Api();
    final bloc = BarcodeBloc(
      _Scanner(),
      ProcessBarcodeUseCase(repo),
      api,
      Settings(),
      repo,
    );
    addTearDown(bloc.close);
    addTearDown(api.dispose);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: _AuthBloc()),
            BlocProvider<BarcodeBloc>.value(value: bloc),
          ],
          child: const BarcodeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (var attempt = 0; attempt < 2; attempt++) {
      await tester.tap(find.text('اضافه بالته جديده'));
      await tester.pumpAndSettle();
      expect(find.text('هل أنت متأكد من إضافة بالتة جديدة؟'), findsOneWidget);
      await tester.tap(find.text('نعم'));
      await tester.pumpAndSettle();
    }
    expect(
      find.text('يجب مسح صندوق واحد على الأقل للبالتة الحالية.'),
      findsOneWidget,
    );
    bloc.add(BarcodeScanned('12345600000000010001', ''));
    await tester.pumpAndSettle();
    expect(repo.items, isEmpty);
    expect(bloc.state.currentExportPalletNo, 1);
    await tester.tap(find.text('إغلاق'));
    await tester.pumpAndSettle();
    bloc.add(BarcodeScanned('12345600000000010001', ''));
    await tester.pumpAndSettle();
    expect(repo.items, hasLength(1));
    await tester.tap(find.text('اضافه بالته جديده'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('نعم'));
    await tester.pumpAndSettle();
    expect(bloc.state.currentExportPalletNo, 2);
    expect(find.byType(ErrorPopup), findsNothing);
  });
  testWidgets('duplicate pallet shows one dialog and saves one new number', (
    tester,
  ) async {
    final repo = EmptyRepository();
    final api = Api();
    final bloc = BarcodeBloc(
      _Scanner(),
      ProcessBarcodeUseCase(repo),
      api,
      Settings(),
      repo,
    );
    addTearDown(bloc.close);
    addTearDown(api.dispose);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: _AuthBloc()),
            BlocProvider<BarcodeBloc>.value(value: bloc),
          ],
          child: const BarcodeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (var n = 0; n < 2; n++) {
      bloc.add(BarcodeScanned('P1234560000000001Z025', ''));
      await tester.pumpAndSettle();
    }
    expect(find.byType(ErrorPopup), findsOneWidget);
    expect(repo.items, hasLength(1));
    await tester.tap(find.text('نعم'));
    await tester.pumpAndSettle();
    expect(find.byType(ErrorPopup), findsNothing);
    expect(repo.items.map((item) => item.exportPalletNo), [1, 2]);
    expect(tester.takeException(), isNull);
  });
  for (final locale in ['en', 'ar']) {
    testWidgets(
      'small $locale screen shows scan controls and actions without scrolling',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(320, 462);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        final repo = EmptyRepository();
        final api = Api();
        final bloc = BarcodeBloc(
          _Scanner(),
          ProcessBarcodeUseCase(repo),
          api,
          Settings(),
          repo,
        );
        addTearDown(bloc.close);
        addTearDown(api.dispose);
        await tester.pumpWidget(
          MaterialApp(
            locale: Locale(locale),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: MultiBlocProvider(
              providers: [
                BlocProvider<AuthBloc>.value(value: _AuthBloc()),
                BlocProvider<BarcodeBloc>.value(value: bloc),
              ],
              child: const BarcodeScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final boxes = find.text('Boxes');
        expect(find.byType(Scrollable), findsNothing);
        expect(boxes.hitTestable(), findsOneWidget);
        final statusSection = find.byType(BarcodeStatusSection);
        final actions = find.byType(BarcodeActionsSection);
        expect(
          tester.getTopLeft(actions).dy -
              tester.getBottomRight(statusSection).dy,
          closeTo(8, 0.1),
        );
        await tester.tap(boxes);
        await tester.pumpAndSettle();
        expect(bloc.state.scanType, ScanType.box);
        expect(
          tester.getBottomRight(find.byType(BarcodeActionsSection)).dy,
          lessThanOrEqualTo(462),
        );
        await tester.pumpAndSettle();
        expect(
          find
              .descendant(of: actions, matching: find.byType(ElevatedButton))
              .hitTestable(),
          findsNWidgets(5),
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
