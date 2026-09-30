import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_count_flutter_app/core/services/dummy_barcode_generator.dart';

void main() {
  test('generates mixed pallet and box data totaling 2000 to 5000 boxes', () {
    final items = DummyBarcodeGenerator(random: Random(7)).generate();

    expect(items.any((item) => item.isPallet), isTrue);
    expect(items.any((item) => !item.isPallet), isTrue);
    expect(
      items.map((item) => item.barCodeNo).toSet(),
      hasLength(items.length),
    );
    final sectionLetters = items
        .where((item) => item.isPallet)
        .map((item) => item.barCodeNo.substring(17, 18))
        .toSet();
    expect(sectionLetters.length, greaterThan(1));
    expect(
      sectionLetters.every((letter) => RegExp(r'^[A-Z]$').hasMatch(letter)),
      isTrue,
    );

    final totalBoxes = items.fold<int>(0, (total, item) {
      if (!item.isPallet) {
        expect(item.barCodeNo, hasLength(20));
        expect(item.palletBox, 'B');
        return total + 1;
      }
      expect(item.barCodeNo, hasLength(21));
      expect(item.barCodeNo.substring(17, 18), matches(RegExp(r'^[A-Z]$')));
      expect(item.palletBox, 'P');
      return total + item.qty;
    });

    expect(totalBoxes, inInclusiveRange(2000, 5000));
  });
}
