class AssetScan {
  final int? id;
  final String barcode;
  final DateTime scannedAt;

  AssetScan({this.id, required this.barcode, required this.scannedAt});

  Map<String, dynamic> toMap() {
    return {
      'barcode': barcode,
      'scannedAt': scannedAt.toIso8601String(),
    };
  }

  factory AssetScan.fromMap(Map<String, dynamic> map) {
    return AssetScan(
      id: map['id'] as int?,
      barcode: map['barcode'] as String,
      scannedAt: DateTime.parse(map['scannedAt'] as String),
    );
  }
}
