class Validator {
  static String? validateBarcode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Barcode is required';
    }

    if (value.length != 20 && value.length != 21) {
      return 'Barcode must be 20 or 21 characters long';
    }

    if (value.length == 21 && !value.startsWith('P')) {
      return '21-character barcode must start with "P"';
    }

    return null;
  }
}
