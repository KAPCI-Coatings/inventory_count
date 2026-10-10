import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_count_flutter_app/domain/entities/barcode.dart';
import 'package:inventory_count_flutter_app/domain/uescases/process_barcode_usecase.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/barcode/barcode_bloc.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/barcode/barcode_event.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/barcode/barcode_state.dart';
import 'barcode_upload_test.dart' show EmptyRepository, Api, Scanner, Settings;

class ControlledRepository extends EmptyRepository {
  bool fail = false;
  Completer<void>? gate;
  @override
  Future<void> saveScannedBarcode(ItemBox item) async {
    if (gate != null) await gate!.future;
    if (fail) throw StateError('save failed');
    await super.saveScannedBarcode(item);
  }

  @override
  Future<int> startNewExportPallet() async {
    if (gate != null) await gate!.future;
    if (fail) throw StateError('reserve failed');
    return super.startNewExportPallet();
  }
}

void main() {
  late ControlledRepository repo;
  late Api api;
  late BarcodeBloc bloc;
  BarcodeBloc createBloc() => BarcodeBloc(
    Scanner(),
    ProcessBarcodeUseCase(repo),
    api,
    Settings(),
    repo,
  );
  Future<void> act(BarcodeEvent event) async {
    final done = bloc.stream.firstWhere(
      (s) => !s.isInventoryMutationInProgress,
    );
    bloc.add(event);
    await done.timeout(const Duration(seconds: 3));
  }

  BarcodeScanned pallet(int n) =>
      BarcodeScanned('P123456${n.toString().padLeft(10, '0')}Z025', '');
  BarcodeScanned box(int n) =>
      BarcodeScanned('1234560000000001${n.toString().padLeft(4, '0')}', '');
  setUp(() {
    repo = ControlledRepository();
    api = Api();
    bloc = createBloc();
  });
  tearDown(() async {
    await bloc.close();
    api.dispose();
  });

  test('pallets and box groups share a continuous local sequence', () async {
    for (var n = 1; n <= 3; n++) {
      await act(pallet(n));
    }
    await act(BarcodeNewPalletRequested());
    expect(bloc.state.scanType, ScanType.box);
    expect(bloc.state.currentExportPalletNo, 4);
    expect(repo.items, hasLength(3));
    expect(bloc.state.palletCount, 3);
    await act(box(1));
    await act(box(2));
    await act(BarcodeNewPalletRequested());
    await act(box(3));
    await act(BarcodeScanTypeChanged(ScanType.pallet));
    await act(pallet(4));
    expect(repo.items.map((i) => i.exportPalletNo), [1, 2, 3, 4, 4, 5, 6]);
    expect(bloc.state.boxCount, 103);
    expect(bloc.state.palletCount, 4);
  });

  test(
    'manual boxes start at one and empty reservation survives restart',
    () async {
      await act(BarcodeScanTypeChanged(ScanType.box));
      expect(bloc.state.currentExportPalletNo, 0);
      await act(box(1));
      await act(box(2));
      expect(repo.items.map((i) => i.exportPalletNo), [1, 1]);
      await act(BarcodeNewPalletRequested());
      await bloc.close();
      bloc = createBloc();
      await act(BarcodeInitializeRequested());
      expect(bloc.state.currentExportPalletNo, 2);
      expect(bloc.state.scanType, ScanType.pallet);
      await act(BarcodeScanTypeChanged(ScanType.box));
      await act(box(3));
      expect(repo.items.last.exportPalletNo, 2);
      await act(BarcodeResetRequested());
      expect(bloc.state.currentExportPalletNo, 2);
      await act(BarcodeNewOrderRequested());
      await act(pallet(1));
      expect(repo.items.single.exportPalletNo, 1);
    },
  );

  test('invalid scans and rejected duplicates do not allocate', () async {
    await act(pallet(1));
    await act(BarcodeScanned('bad', ''));
    expect(bloc.state.currentExportPalletNo, 1);
    await act(pallet(1));
    expect(bloc.state.status, BarcodeStatus.warning);
    expect(repo.currentNumber, 1);
    bloc.add(BarcodeNewPalletRequested());
    bloc.add(BarcodeScanTypeChanged(ScanType.box));
    bloc.add(BarcodePostCurrentOrderRequested());
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.currentExportPalletNo, 1);
    expect(bloc.state.scanType, ScanType.pallet);
    expect(api.sizes, isEmpty);
    await act(BarcodeDuplicateRejected());
    await act(pallet(1));
    await act(BarcodeDuplicateConfirmed());
    expect(repo.items.map((i) => i.exportPalletNo), [1, 2]);
    bloc.add(BarcodeDuplicateConfirmed());
    await Future<void>.delayed(Duration.zero);
    expect(repo.items, hasLength(2));
    await act(BarcodeScanTypeChanged(ScanType.box));
    await act(box(1));
    await act(box(1));
    expect(bloc.state.currentExportPalletNo, 2);
    expect(repo.items, hasLength(3));
  });

  test('upload retains local group and the next box uses it', () async {
    await act(pallet(1));
    await act(BarcodeNewPalletRequested());
    await act(box(1));
    await act(BarcodePostCurrentOrderRequested());
    expect(bloc.state.currentExportPalletNo, 2);
    expect(repo.currentNumber, 2);
    await act(box(2));
    expect(repo.items.map((i) => i.exportPalletNo), [1, 2, 2]);
  });

  test('failed writes and reservations can be retried without gaps', () async {
    repo.fail = true;
    await act(pallet(1));
    expect(bloc.state.currentExportPalletNo, 0);
    await act(BarcodeNewPalletRequested());
    expect(bloc.state.scanType, ScanType.pallet);
    expect(bloc.state.currentExportPalletNo, 0);
    repo.fail = false;
    await act(pallet(1));
    await act(pallet(1));
    repo.fail = true;
    await act(BarcodeDuplicateConfirmed());
    expect(repo.currentNumber, 1);
    expect(bloc.state.status, BarcodeStatus.warning);
    repo.fail = false;
    await act(BarcodeDuplicateConfirmed());
    expect(repo.items.map((i) => i.exportPalletNo), [1, 2]);
  });

  test('overlapping actions cannot change a scan or reserved group', () async {
    repo.gate = Completer<void>();
    final busy = bloc.stream.firstWhere((s) => s.isInventoryMutationInProgress);
    bloc.add(pallet(1));
    await busy;
    bloc.add(BarcodeNewPalletRequested());
    bloc.add(BarcodeNewOrderRequested());
    bloc.add(BarcodePostCurrentOrderRequested());
    await Future<void>.delayed(Duration.zero);
    final done = bloc.stream.firstWhere(
      (s) => !s.isInventoryMutationInProgress,
    );
    repo.gate!.complete();
    await done;
    expect(repo.items.single.exportPalletNo, 1);
    expect(api.sizes, isEmpty);
    repo.gate = Completer<void>();
    final reserving = bloc.stream.firstWhere(
      (s) => s.isInventoryMutationInProgress,
    );
    bloc.add(BarcodeNewPalletRequested());
    await reserving;
    bloc.add(pallet(2));
    await Future<void>.delayed(Duration.zero);
    final reserved = bloc.stream.firstWhere(
      (s) => !s.isInventoryMutationInProgress,
    );
    repo.gate!.complete();
    await reserved;
    repo.gate = null;
    expect(repo.items, hasLength(1));
    await act(box(1));
    expect(repo.items.last.exportPalletNo, 2);
  });
}
