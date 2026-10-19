import 'dart:math';

import 'package:inventory_count_flutter_app/domain/entities/barcode.dart';

/// Creates inventory records used only for load-testing the existing workflow.
class DummyBarcodeGenerator {
  DummyBarcodeGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;

  List<ItemBox> generate({int minBoxes = 2000, int maxBoxes = 5000}) {
    if (minBoxes < 2 || maxBoxes < minBoxes) {
      throw ArgumentError('Expected 2 <= minBoxes <= maxBoxes.');
    }

    final target = minBoxes + _random.nextInt(maxBoxes - minBoxes + 1);
    final maximumIndividuals = min(50, target - 1);
    final minimumIndividuals = min(10, maximumIndividuals);
    final individualBoxCount =
        minimumIndividuals +
        _random.nextInt(maximumIndividuals - minimumIndividuals + 1);
    var palletBoxesRemaining = target - individualBoxCount;
    var palletNumber = 1;
    final items = <ItemBox>[];
    final generatedBarcodes = <String>{};

    while (palletBoxesRemaining > 0) {
      final quantity = min(palletBoxesRemaining, 20 + _random.nextInt(81));
      palletBoxesRemaining -= quantity;
      final sectionLetter = String.fromCharCode(65 + _random.nextInt(26));
      final serialNo = '$sectionLetter${quantity.toString().padLeft(3, '0')}';
      final fields = _uniqueFields(
        generatedBarcodes,
        (matnr, batch, serial) =>
            'P$matnr$batch$serialNo',
      );
      items.add(
        ItemBox(
          barCodeNo: fields.barcode,
          matnr: fields.matnr,
          batchNo: fields.batch,
          serialNo: serialNo,
          palletBox: 'P',
          palletNo: palletNumber++,
          qty: quantity,
          isPallet: true,
        ),
      );
    }

    for (var index = 0; index < individualBoxCount; index++) {
      final fields = _uniqueFields(
        generatedBarcodes,
        (matnr, batch, serial) => '$matnr$batch$serial',
      );
      items.add(
        ItemBox(
          barCodeNo: fields.barcode,
          matnr: fields.matnr,
          batchNo: fields.batch,
          serialNo: fields.serial,
          palletBox: 'B',
          palletNo: 1,
          qty: 1,
        ),
      );
    }

    items.shuffle(_random);
    return items;
  }

  _BarcodeFields _uniqueFields(
    Set<String> generated,
    String Function(String matnr, String batch, String serial) build,
  ) {
    while (true) {
      final matnr = _digits(6);
      final batch = _digits(10);
      final serial = _digits(4);
      final barcode = build(matnr, batch, serial);
      if (generated.add(barcode)) {
        return _BarcodeFields(barcode, matnr, batch, serial);
      }
    }
  }

  String _digits(int length) =>
      List.generate(length, (_) => _random.nextInt(10), growable: false).join();
}

class _BarcodeFields {
  const _BarcodeFields(this.barcode, this.matnr, this.batch, this.serial);

  final String barcode;
  final String matnr;
  final String batch;
  final String serial;
}
