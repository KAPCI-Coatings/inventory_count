import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class ItemBox extends Equatable {
  static final DateFormat _apiDateFormat = DateFormat('yyyy-MM-ddTHH:mm:ss');

  final String matnr;
  final int qty;
  final String batchNo;
  final String serialNo;
  final String barCodeNo;
  final String palletBox;
  final DateTime readDate;
  final bool isPallet;

  const ItemBox({
    required this.matnr,
    required this.qty,
    required this.batchNo,
    required this.serialNo,
    required this.barCodeNo,
    required this.palletBox,
    required this.readDate,
    this.isPallet = false,
  });

  /// Returns true when the raw barcode represents a pallet scan
  /// (21 characters, starting with 'P').
  static bool isPalletBarcode(String barcode) {
    final String normalized = barcode.replaceAll(RegExp(r'\s+'), '').trim();
    return normalized.length == 21 &&
        normalized[0].toUpperCase() == 'P';
  }

  /// Parses a raw barcode into an [ItemBox].
  ///
  /// **Box barcode** – exactly 20 digits:
  ///   Material (6) + Batch (10) + Serial (4).
  ///
  /// **Pallet barcode** – exactly 21 characters, starts with 'P':
  ///   P + Material (6) + Batch (10) + PalletType (1 letter) + QTY (3 digits).
  factory ItemBox.fromBarcode({
    required String barcode,
    required String palletBox,
    DateTime? readDate,
  }) {
    final String normalized = barcode.replaceAll(RegExp(r'\s+'), '').trim();

    // ── Pallet barcode (21 chars, starts with P) ──
    if (isPalletBarcode(normalized)) {
      final String body = normalized.substring(1); // remove leading 'P'
      final String material = body.substring(0, 6);
      final String batch = body.substring(6, 16);
      final String palletType = body.substring(16, 17); // letter like Z, B, C
      final String qtyPart = body.substring(17, 20);
      final int? parsedQty = int.tryParse(qtyPart);
      final int qty = (parsedQty != null && parsedQty > 0) ? parsedQty : 1;

      return ItemBox(
        matnr: material,
        qty: qty,
        batchNo: batch,
        serialNo: palletType, // store pallet type letter in serialNo
        barCodeNo: normalized,
        palletBox: palletType,
        readDate: readDate ?? DateTime.now(),
        isPallet: true,
      );
    }

    // ── Box barcode (20 digits) ──
    final String digitsOnly = RegExp(
      r'\d',
    ).allMatches(normalized).map((Match match) => match.group(0)!).join();

    if (digitsOnly.length < 20) {
      throw const FormatException(
        'باركود غير صحيح. يجب أن يكون 20 أو 21 حرف بالضبط.',
      );
    }

    final String code20 = digitsOnly.substring(0, 20);
    int qty = 1;

    if (digitsOnly.length > 20) {
      final String qtyPart = digitsOnly.substring(20);
      final int? parsedQty = int.tryParse(qtyPart);
      if (parsedQty != null && parsedQty > 0) {
        qty = parsedQty;
      }
    }

    return ItemBox(
      matnr: code20.substring(0, 6),
      qty: qty,
      batchNo: code20.substring(6, 16),
      serialNo: code20.substring(16, 20),
      barCodeNo: code20,
      palletBox: palletBox,
      readDate: readDate ?? DateTime.now(),
      isPallet: false,
    );
  }

  factory ItemBox.fromCacheJson(Map<String, dynamic> json) {
    return ItemBox(
      matnr: (json['matnr'] as String?) ?? '',
      qty: (json['qty'] as num?)?.toInt() ?? 1,
      batchNo: (json['batch_No'] as String?) ?? '',
      serialNo: (json['serial_No'] as String?) ?? '',
      barCodeNo: (json['barCode_No'] as String?) ?? '',
      palletBox: (json['palletBox'] as String?) ?? 'B',
      readDate:
          DateTime.tryParse((json['read_Date'] as String?) ?? '') ??
          DateTime.now(),
      isPallet: (json['isPallet'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toApiJson() {
    return <String, dynamic>{
      'matnr': matnr,
      'qty': qty,
      'batch_No': batchNo,
      'serial_No': serialNo,
      'barCode_No': barCodeNo,
      'palletBox': palletBox,
      'read_Date': _apiDateFormat.format(readDate),
      'isPallet': isPallet,
    };
  }

  Map<String, dynamic> toCacheJson() => toApiJson();

  @override
  List<Object?> get props => <Object?>[
    matnr,
    qty,
    batchNo,
    serialNo,
    barCodeNo,
    palletBox,
    readDate,
    isPallet,
  ];
}
