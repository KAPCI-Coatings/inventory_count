import 'package:inventory_count_flutter_app/domain/entities/barcode.dart';

enum BarcodeStatus { initial, loading, posting, success, error }

class BarcodeState {
  final String? message;
  final String? centeredErrorMessage;
  final String? centeredSuccessMessage;
  final String? centeredWarningMessage;
  final BarcodeStatus status;
  final ItemBox? lastScan;
  final int palletBoxCount;
  final int boxCount;
  final int palletCount;
  final int dailyScanCount;
  final List<ItemBox> itemBoxes;

  const BarcodeState({
    this.message,
    this.centeredErrorMessage,
    this.centeredSuccessMessage,
    this.centeredWarningMessage,
    this.status = BarcodeStatus.initial,
    this.lastScan,
    this.palletBoxCount = 0,
    this.boxCount = 0,
    this.palletCount = 0,
    this.dailyScanCount = 0,
    this.itemBoxes = const [],
  });
}
