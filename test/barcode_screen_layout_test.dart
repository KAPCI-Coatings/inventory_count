import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_count_flutter_app/core/services/scanner_service.dart';
import 'package:inventory_count_flutter_app/l10n/app_localizations.dart';
import 'package:inventory_count_flutter_app/domain/uescases/process_barcode_usecase.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/auth/auth_bloc.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/auth/auth_state.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/barcode/barcode_bloc.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/barcode/barcode_state.dart';
import 'package:inventory_count_flutter_app/presentation/views/barcode_screen.dart';
import 'package:inventory_count_flutter_app/presentation/widgets/barcode/barcode_actions_section.dart';
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
  for (final locale in ['en', 'ar']) {
    testWidgets('small $locale screen shows scan controls and actions without scrolling', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 462);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final repo = EmptyRepository();
      final api = Api();
      final bloc = BarcodeBloc(_Scanner(), ProcessBarcodeUseCase(repo), api, Settings(), repo);
      addTearDown(bloc.close);
      addTearDown(api.dispose);
      await tester.pumpWidget(MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MultiBlocProvider(providers: [
          BlocProvider<AuthBloc>.value(value: _AuthBloc()),
          BlocProvider<BarcodeBloc>.value(value: bloc),
        ], child: const BarcodeScreen()),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final boxes = find.text(locale == 'en' ? 'Boxes' : 'صناديق');
      expect(find.byType(Scrollable), findsNothing);
      expect(boxes.hitTestable(), findsOneWidget);
      final radioRow = find.byType(RadioGroup<ScanType>);
      final actions = find.byType(BarcodeActionsSection);
      expect(
        tester.getTopLeft(actions).dy - tester.getBottomRight(radioRow).dy,
        closeTo(8, 0.1),
      );
      await tester.tap(boxes);
      await tester.pumpAndSettle();
      expect(bloc.state.scanType, ScanType.box);
      expect(tester.getBottomRight(find.byType(BarcodeActionsSection)).dy, lessThanOrEqualTo(462));
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: actions, matching: find.byType(ElevatedButton)).hitTestable(),
        findsNWidgets(4),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
