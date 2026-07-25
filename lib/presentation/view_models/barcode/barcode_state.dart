import 'package:equatable/equatable.dart';
import 'package:inventory_count_flutter_app/domain/entities/barcode.dart';

enum BarcodeStatus { initial, loading, posting, success, warning, error }

class BarcodeState extends Equatable {
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

  /// True while a POST request to the backend is in progress.
  final bool isSending;

  /// Human-readable feedback from the last send attempt.
  final String? sendResultMessage;

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
    this.isSending = false,
    this.sendResultMessage,
  });

  BarcodeState copyWith({
    String? message,
    String? centeredErrorMessage,
    String? centeredSuccessMessage,
    String? centeredWarningMessage,
    BarcodeStatus? status,
    ItemBox? lastScan,
    int? palletBoxCount,
    int? boxCount,
    int? palletCount,
    int? dailyScanCount,
    List<ItemBox>? itemBoxes,
    bool? isSending,
    String? sendResultMessage,
  }) {
    return BarcodeState(
      message: message ?? this.message,
      centeredErrorMessage: centeredErrorMessage ?? this.centeredErrorMessage,
      centeredSuccessMessage: centeredSuccessMessage ?? this.centeredSuccessMessage,
      centeredWarningMessage: centeredWarningMessage ?? this.centeredWarningMessage,
      status: status ?? this.status,
      lastScan: lastScan ?? this.lastScan,
      palletBoxCount: palletBoxCount ?? this.palletBoxCount,
      boxCount: boxCount ?? this.boxCount,
      palletCount: palletCount ?? this.palletCount,
      dailyScanCount: dailyScanCount ?? this.dailyScanCount,
      itemBoxes: itemBoxes ?? this.itemBoxes,
      isSending: isSending ?? this.isSending,
      sendResultMessage: sendResultMessage ?? this.sendResultMessage,
    );
  }

  @override
  List<Object?> get props => [
        message,
        centeredErrorMessage,
        centeredSuccessMessage,
        centeredWarningMessage,
        status,
        lastScan,
        palletBoxCount,
        boxCount,
        palletCount,
        dailyScanCount,
        itemBoxes,
        isSending,
        sendResultMessage,
      ];
}
