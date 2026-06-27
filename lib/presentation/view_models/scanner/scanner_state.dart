import 'package:equatable/equatable.dart';

import '../../../../domain/entities/item_box.dart';

enum ScannerStatus { initial, loading, ready, posting, postSuccess, error }

class ScannerState extends Equatable {
  static const Object _noValue = Object();

  final ScannerStatus status;
  final String activeProfile;
  final ItemBox? lastScan;
  final List<ItemBox> itemBoxes;
  final List<ItemBox> currentOrderItemBoxes;
  final int palletCount;
  final int dailyScanCount;
  final String dailyKey;
  final String baseUrl;
  final int deviceId;
  final String? message;
  final String? centeredErrorMessage;
  final String? centeredSuccessMessage;
  final String? centeredWarningMessage;
  final ItemBox? pendingDuplicatePallet;
  final bool isScannerEnabled;

  const ScannerState({
    this.status = ScannerStatus.initial,
    this.activeProfile = 'APP_PROFILE',
    this.lastScan,
    this.itemBoxes = const <ItemBox>[],
    this.currentOrderItemBoxes = const <ItemBox>[],
    this.palletCount = 0,
    this.dailyScanCount = 0,
    this.dailyKey = '',
    this.baseUrl = 'http://10.10.30.47:2604',
    this.deviceId = 0,
    this.message,
    this.centeredErrorMessage,
    this.centeredSuccessMessage,
    this.centeredWarningMessage,
    this.pendingDuplicatePallet,
    this.isScannerEnabled = true,
  });

  int get boxCount => currentOrderItemBoxes.fold<int>(
    0,
    (int total, ItemBox item) => total + item.qty,
  );

  int get palletBoxCount {
    if (lastScan == null) return 0;
    return currentOrderItemBoxes
        .where((ItemBox item) => item.palletBox == lastScan!.palletBox)
        .fold<int>(0, (int total, ItemBox item) => total + item.qty);
  }

  ScannerState copyWith({
    ScannerStatus? status,
    String? activeProfile,
    Object? lastScan = _noValue,
    List<ItemBox>? itemBoxes,
    List<ItemBox>? currentOrderItemBoxes,
    int? palletCount,
    int? dailyScanCount,
    String? dailyKey,
    String? baseUrl,
    int? deviceId,
    Object? message = _noValue,
    Object? centeredErrorMessage = _noValue,
    Object? centeredSuccessMessage = _noValue,
    Object? centeredWarningMessage = _noValue,
    Object? pendingDuplicatePallet = _noValue,
    bool? isScannerEnabled,
  }) {
    return ScannerState(
      status: status ?? this.status,
      activeProfile: activeProfile ?? this.activeProfile,
      lastScan: identical(lastScan, _noValue) ? this.lastScan : lastScan as ItemBox?,
      itemBoxes: itemBoxes ?? this.itemBoxes,
      currentOrderItemBoxes:
          currentOrderItemBoxes ?? this.currentOrderItemBoxes,
      palletCount: palletCount ?? this.palletCount,
      dailyScanCount: dailyScanCount ?? this.dailyScanCount,
      dailyKey: dailyKey ?? this.dailyKey,
      baseUrl: baseUrl ?? this.baseUrl,
      deviceId: deviceId ?? this.deviceId,
      message: identical(message, _noValue) ? this.message : message as String?,
      centeredErrorMessage: identical(centeredErrorMessage, _noValue)
          ? this.centeredErrorMessage
          : centeredErrorMessage as String?,
      centeredSuccessMessage: identical(centeredSuccessMessage, _noValue)
          ? this.centeredSuccessMessage
          : centeredSuccessMessage as String?,
      centeredWarningMessage: identical(centeredWarningMessage, _noValue)
          ? this.centeredWarningMessage
          : centeredWarningMessage as String?,
      pendingDuplicatePallet: identical(pendingDuplicatePallet, _noValue)
          ? this.pendingDuplicatePallet
          : pendingDuplicatePallet as ItemBox?,
      isScannerEnabled: isScannerEnabled ?? this.isScannerEnabled,
    );
  }

  @override
  List<Object?> get props => [
    status,
    activeProfile,
    lastScan,
    itemBoxes,
    currentOrderItemBoxes,
    palletCount,
    dailyScanCount,
    dailyKey,
    baseUrl,
    deviceId,
    message,
    centeredErrorMessage,
    centeredSuccessMessage,
    centeredWarningMessage,
    pendingDuplicatePallet,
    isScannerEnabled,
  ];
}
