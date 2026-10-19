import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_count_flutter_app/domain/entities/barcode.dart';
import 'package:inventory_count_flutter_app/l10n/app_localizations.dart';
import 'package:inventory_count_flutter_app/presentation/widgets/search/search_results_table.dart';

void main() {
  const sampleItems = [
    ItemBox(
      matnr: '100001',
      batchNo: '0000000001',
      serialNo: '0001',
      isPallet: false,
      palletBox: 'B',
      qty: 1,
      exportPalletNo: 1,
    ),
    ItemBox(
      matnr: '100002',
      batchNo: '0000000002',
      serialNo: '0002',
      isPallet: true,
      palletBox: 'P',
      qty: 25,
      exportPalletNo: 2,
    ),
  ];

  testWidgets('renders all excel columns and rows in english', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: SizedBox(
            height: 400,
            width: 600,
            child: SearchResultsTable(
              items: sampleItems,
              totalQty: 26,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Check Excel headers
    expect(find.text('#'), findsNothing);
    expect(find.text('Pallet Number'), findsOneWidget);
    expect(find.text('Material'), findsOneWidget);
    expect(find.text('Batch No'), findsOneWidget);
    expect(find.text('Serial No'), findsOneWidget);
    expect(find.text('Pallet/Box'), findsOneWidget);
    expect(find.text('Quantity'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Pallet Number')).dx <
          tester.getTopLeft(find.text('Material')).dx,
      isTrue,
    );

    // Check data row values
    expect(find.text('100001'), findsOneWidget);
    expect(find.text('0000000001'), findsOneWidget);
    expect(find.text('0001'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(find.text('1'), findsNWidgets(2)); // qty 1 + palletNo 1

    expect(find.text('100002'), findsOneWidget);
    expect(find.text('0000000002'), findsOneWidget);
    expect(find.text('P'), findsOneWidget);
    expect(find.text('25'), findsOneWidget);

    // Check total row
    expect(find.textContaining('26'), findsOneWidget);
  });

  testWidgets('renders all excel columns and rows in arabic', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: SizedBox(
            height: 400,
            width: 600,
            child: SearchResultsTable(
              items: sampleItems,
              totalQty: 26,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Check Arabic headers
    expect(find.text('م.'), findsNothing);
    expect(find.text('رقم البالتة'), findsOneWidget);
    expect(find.text('المادة'), findsOneWidget);
    expect(find.text('رقم التشغيلة'), findsOneWidget);
    expect(find.text('الرقم التسلسلي'), findsOneWidget);
    expect(find.text('باليتة/صندوق'), findsOneWidget);
    expect(find.text('الكمية'), findsOneWidget);
    expect(
      tester.getTopRight(find.text('رقم البالتة')).dx >
          tester.getTopRight(find.text('المادة')).dx,
      isTrue,
    );

    // Check total row in Arabic
    expect(find.textContaining('26'), findsOneWidget);
  });

  testWidgets('renders empty placeholder when items list is empty', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: SizedBox(
            height: 400,
            width: 600,
            child: SearchResultsTable(
              items: [],
              totalQty: 0,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('— No scanned barcodes yet. —'), findsOneWidget);
    expect(find.textContaining('0'), findsOneWidget);
  });
}
