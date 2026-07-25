abstract class BarcodeEvent {}

class BarcodeInitializeRequested extends BarcodeEvent {}

class BarcodeClearMessageRequested extends BarcodeEvent {}

class BarcodeDismissCenteredMessageRequested extends BarcodeEvent {}

class BarcodeDuplicateConfirmed extends BarcodeEvent {}

class BarcodeDuplicateRejected extends BarcodeEvent {}

/// Sends all scanned barcodes to the backend configured in Settings.
class BarcodePostCurrentOrderRequested extends BarcodeEvent {}

/// Resets the current screen state (counts, last scan, messages) but does
/// NOT delete data from the database cache.
class BarcodeNewOrderRequested extends BarcodeEvent {}

/// Hard reset — clears both screen state and DB session.
class BarcodeResetRequested extends BarcodeEvent {}

// Scanner Events
class BarcodeScannerEnableRequested extends BarcodeEvent {}

class BarcodeScannerDisableRequested extends BarcodeEvent {}

class BarcodeScanned extends BarcodeEvent {
  final String barcode;
  final String labelType;
  BarcodeScanned(this.barcode, this.labelType);
}
