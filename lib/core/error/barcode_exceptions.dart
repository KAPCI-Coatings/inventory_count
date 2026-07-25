class BarcodeException implements Exception {
  final String message;
  const BarcodeException(this.message);

  @override
  String toString() => message;
}

class InvalidBarcodeFormatException extends BarcodeException {
  const InvalidBarcodeFormatException(super.message);
}

/// No longer thrown for duplicate barcodes — duplicates are now allowed
/// but surface a warning via [ProcessBarcodeResult.isDuplicate].
/// Kept for backwards-compatibility / future use.
class DuplicateBarcodeException extends BarcodeException {
  const DuplicateBarcodeException(super.message);
}
