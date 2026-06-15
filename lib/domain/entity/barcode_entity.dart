class BarcodeEntity {
  final String id;
  final bool isPalette;
  final String batchNo;
  final String materialNo;
  final String barcode;

  final int quantity;

  final String boxSerial;

  final String paletteLetter;

  BarcodeEntity({
    this.id = "",
    this.isPalette = false,
    this.batchNo = "",
    this.materialNo = "",
    this.barcode = "",
    this.quantity = 0,
    this.boxSerial = "",
    this.paletteLetter = "",
  });

  BarcodeEntity copyWith({
    String? id,
    bool? isPalette,
    String? batchNo,
    String? materialNo,
    String? barcode,
    int? quantity,
    String? boxSerial,
    String? paletteLetter,
  }) {
    return BarcodeEntity(
      id: id ?? this.id,
      isPalette: isPalette ?? this.isPalette,
      batchNo: batchNo ?? this.batchNo,
      materialNo: materialNo ?? this.materialNo,
      barcode: barcode ?? this.barcode,
      quantity: quantity ?? this.quantity,
      boxSerial: boxSerial ?? this.boxSerial,
      paletteLetter: paletteLetter ?? this.paletteLetter,
    );
  }

  @override
  String toString() {
    return 'BarcodeEntity(id: $id, isPalette: $isPalette,'
        ' batchNo: $batchNo, materialNo: $materialNo, barcode: $barcode,'
        ' quantity: $quantity, boxSerial: $boxSerial, '
        'paletteLetter: $paletteLetter)';
  }
}
