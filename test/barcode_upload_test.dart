import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:inventory_count_flutter_app/core/services/dummy_barcode_generator.dart';
import 'package:inventory_count_flutter_app/core/widgets/sending_progress_popup.dart';
import 'package:inventory_count_flutter_app/core/services/api_service.dart';
import 'package:inventory_count_flutter_app/core/services/scanner_service.dart';
import 'package:inventory_count_flutter_app/data/datasources/settings_local_datasource.dart';
import 'package:inventory_count_flutter_app/domain/entities/barcode.dart';
import 'package:inventory_count_flutter_app/domain/repositories/barcode_repository.dart';
import 'package:inventory_count_flutter_app/domain/uescases/process_barcode_usecase.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/barcode/barcode_bloc.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/barcode/barcode_event.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/barcode/barcode_state.dart';

class Repository extends Fake implements BarcodeRepository {
  final items = List.generate(121, (i) => ItemBox(barCodeNo: '$i'));
  final sent = <String>{};
  @override
  Future<List<ItemBox>> getScannedItems({
    String? matnr,
    String? batchNo,
  }) async => items
      .map(
        (i) =>
            ItemBox(barCodeNo: i.barCodeNo, isSent: sent.contains(i.barCodeNo)),
      )
      .toList();
  @override
  Future<void> markAsSent(List<String> barcodes) async {
    sent.addAll(barcodes);
  }
}

class Api extends ApiService {
  final sizes = <int>[];
  bool failSecond = false;
  @override
  Future<ApiPostResult> sendInventoryData({
    required String baseUrl,
    required String devId,
    required List<ItemBox> items,
    required int count,
  }) async {
    expect(count, items.length);
    sizes.add(items.length);
    return failSecond && sizes.length == 2
        ? const ApiPostResult.failure('error_post_no_connection')
        : const ApiPostResult.success();
  }
}

class Settings extends Fake implements SettingsLocalDataSource {
  @override
  String getBaseUrl() => 'http://localhost';
  @override
  String getDevId() => '1';
}

class Scanner extends Fake implements ScannerService {
  @override
  Future<void> enableScanner() async {}
}

class EmptyRepository extends Fake implements BarcodeRepository {
  final List<ItemBox> items = [];

  @override
  Future<bool> isDuplicate(String barcodeNo) async =>
      items.any((item) => item.barCodeNo == barcodeNo);

  @override
  Future<void> saveScannedBarcode(ItemBox item) async => items.add(item);

  @override
  Future<List<ItemBox>> getScannedItems({
    String? matnr,
    String? batchNo,
  }) async => List.unmodifiable(items);
}

void main() {
  test(
    'dummy request stores a mixed batch totaling 2000 to 5000 boxes',
    () async {
      final repo = EmptyRepository();
      final api = Api();
      final bloc = BarcodeBloc(
        Scanner(),
        ProcessBarcodeUseCase(repo),
        api,
        Settings(),
        repo,
        dummyBarcodeGenerator: DummyBarcodeGenerator(random: Random(7)),
      );

      final done = bloc.stream.firstWhere(
        (state) =>
            state.status == BarcodeStatus.success && state.itemBoxes.isNotEmpty,
      );
      bloc.add(BarcodeDummyDataRequested());
      final state = await done;

      expect(state.itemBoxes.any((item) => item.isPallet), isTrue);
      expect(state.itemBoxes.any((item) => !item.isPallet), isTrue);
      expect(state.boxCount, inInclusiveRange(2000, 5000));
      expect(repo.items, hasLength(state.itemBoxes.length));
      await bloc.close();
      api.dispose();
    },
  );

  test('uploads sequential batches of 50 and retains all records', () async {
    final repo = Repository();
    final api = Api();
    final bloc = BarcodeBloc(
      Scanner(),
      ProcessBarcodeUseCase(repo),
      api,
      Settings(),
      repo,
    );
    final progress = <int>[];
    final subscription = bloc.stream
        .where((s) => s.isSending)
        .listen((s) => progress.add(s.sentCount));
    final done = bloc.stream.firstWhere(
      (s) => s.status == BarcodeStatus.success,
    );
    bloc.add(BarcodePostCurrentOrderRequested());
    await done;
    expect(api.sizes, [50, 50, 21]);
    expect(repo.sent.length, 121);
    expect(progress, [0, 50, 100, 121]);
    expect(bloc.state.hasPendingItems, false);
    await subscription.cancel();
    expect((await repo.getScannedItems()).length, 121);
    await bloc.close();
    api.dispose();
  });
  test(
    'failure keeps pending records and restart retries only unsent records',
    () async {
      final repo = Repository();
      final api = Api()..failSecond = true;
      var bloc = BarcodeBloc(
        Scanner(),
        ProcessBarcodeUseCase(repo),
        api,
        Settings(),
        repo,
      );
      final failed = bloc.stream.firstWhere(
        (s) => s.status == BarcodeStatus.error,
      );
      bloc.add(BarcodePostCurrentOrderRequested());
      await failed;
      expect(repo.sent.length, 50);
      expect(bloc.state.hasPendingItems, true);
      expect(bloc.state.isSending, false);
      await bloc.close();
      api.failSecond = false;
      bloc = BarcodeBloc(
        Scanner(),
        ProcessBarcodeUseCase(repo),
        api,
        Settings(),
        repo,
      );
      final done = bloc.stream.firstWhere(
        (s) => s.status == BarcodeStatus.success,
      );
      bloc.add(BarcodePostCurrentOrderRequested());
      await done;
      expect(api.sizes, [50, 50, 50, 21]);
      expect(repo.sent.length, 121);
      await bloc.close();
      api.dispose();
    },
  );
  test('all sent records cause no further requests', () async {
    final repo = Repository();
    repo.sent.addAll(repo.items.map((i) => i.barCodeNo));
    final api = Api();
    final bloc = BarcodeBloc(
      Scanner(),
      ProcessBarcodeUseCase(repo),
      api,
      Settings(),
      repo,
    );
    final done = bloc.stream.first;
    bloc.add(BarcodePostCurrentOrderRequested());
    await done;
    expect(api.sizes, isEmpty);
    expect(bloc.state.hasPendingItems, false);
    await bloc.close();
    api.dispose();
  });
  testWidgets('popup shows confirmed count and percentage instead of timer', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SendingProgressPopup(sentCount: 50, totalToSend: 100),
      ),
    );
    expect(find.text('50 / 100 — 50%'), findsOneWidget);
    expect(
      tester
          .widget<CircularProgressIndicator>(
            find.byType(CircularProgressIndicator),
          )
          .value,
      0.5,
    );
    expect(find.text('00:00'), findsNothing);
  });
}
