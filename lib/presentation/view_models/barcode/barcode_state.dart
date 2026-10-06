import 'package:equatable/equatable.dart';
import 'package:inventory_count_flutter_app/domain/entities/barcode.dart';

enum BarcodeStatus { initial, loading, posting, success, warning, error }

enum ScanType { pallet, box }

class BarcodeState extends Equatable {
  final ScanType scanType;
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
  final int sentCount;
  final int totalToSend;
  bool get hasPendingItems => itemBoxes.any((item) => !item.isSent);

  /// Human-readable feedback from the last send attempt.
  final String? sendResultMessage;

  const BarcodeState({
    this.scanType = ScanType.pallet,
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
    this.sentCount = 0,
    this.totalToSend = 0,
    this.sendResultMessage,
  });

  BarcodeState copyWith({
    ScanType? scanType,
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
    int? sentCount,
    int? totalToSend,
    String? sendResultMessage,
  }) {
    return BarcodeState(
      scanType: scanType ?? this.scanType,
      message: message ?? this.message,
      centeredErrorMessage: centeredErrorMessage ?? this.centeredErrorMessage,
      centeredSuccessMessage:
          centeredSuccessMessage ?? this.centeredSuccessMessage,
      centeredWarningMessage:
          centeredWarningMessage ?? this.centeredWarningMessage,
      status: status ?? this.status,
      lastScan: lastScan ?? this.lastScan,
      palletBoxCount: palletBoxCount ?? this.palletBoxCount,
      boxCount: boxCount ?? this.boxCount,
      palletCount: palletCount ?? this.palletCount,
      dailyScanCount: dailyScanCount ?? this.dailyScanCount,
      itemBoxes: itemBoxes ?? this.itemBoxes,
      isSending: isSending ?? this.isSending,
      sentCount: sentCount ?? this.sentCount,
      totalToSend: totalToSend ?? this.totalToSend,
      sendResultMessage: sendResultMessage ?? this.sendResultMessage,
    );
  }

  @override
  List<Object?> get props => [
    scanType,
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
    sentCount,
    totalToSend,
    sendResultMessage,
  ];
}
