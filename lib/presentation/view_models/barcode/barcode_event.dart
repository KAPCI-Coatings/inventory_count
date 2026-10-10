import 'barcode_state.dart';

abstract class BarcodeEvent {}

class BarcodeScanTypeChanged extends BarcodeEvent {
  final ScanType scanType;
  BarcodeScanTypeChanged(this.scanType);
}

class BarcodeInitializeRequested extends BarcodeEvent {}

/// Reserves the next local Excel group and switches to box scanning.
class BarcodeNewPalletRequested extends BarcodeEvent {}

class BarcodeClearMessageRequested extends BarcodeEvent {}

class BarcodeDismissCenteredMessageRequested extends BarcodeEvent {}

class BarcodeDuplicateConfirmed extends BarcodeEvent {}

class BarcodeDuplicateRejected extends BarcodeEvent {}

/// Sends all scanned barcodes to the backend configured in Settings.
class BarcodePostCurrentOrderRequested extends BarcodeEvent {}

/// Generates scanner-shaped test data and stores it through the normal flow.
class BarcodeDummyDataRequested extends BarcodeEvent {}

/// Clears inventory and resets its local numbering sequence.
class BarcodeNewOrderRequested extends BarcodeEvent {}

/// Resets screen state while retaining cached inventory and numbering.
class BarcodeResetRequested extends BarcodeEvent {}

// Scanner Events
class BarcodeScannerEnableRequested extends BarcodeEvent {}

class BarcodeScannerDisableRequested extends BarcodeEvent {}

class BarcodeScanned extends BarcodeEvent {
  final String barcode;
  final String labelType;
  BarcodeScanned(this.barcode, this.labelType);
}
