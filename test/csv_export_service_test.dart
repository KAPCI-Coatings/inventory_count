import 'package:flutter_test/flutter_test.dart';
import 'package:excel_plus/excel_plus.dart';
import 'package:inventory_count_flutter_app/core/services/csv_export_service.dart';
import 'package:inventory_count_flutter_app/domain/entities/barcode.dart';

void main() {
  test(
    'XLSX preserves complete batch codes as text and sums numeric quantity',
    () {
      final bytes = CsvExportService().buildInventoryXlsx(const [
        ItemBox(
          matnr: '001234',
          batchNo: '0000000123',
          serialNo: '0002',
          qty: 1,
        ),
        ItemBox(
          matnr: '112233',
          batchNo: '5577880000',
          isPallet: true,
          qty: 25,
        ),
        ItemBox(
          matnr: '000000',
          batchNo: '0000000000',
          serialNo: '0000',
          qty: 0,
        ),
      ]);
      final book = Excel.decodeBytes(bytes);
      final sheet = book['Inventory'];
      Data cell(String ref) => sheet.cell(CellIndex.indexByString(ref));
      expect(cell('A2').value, IntCellValue(1234));
      expect(cell('A2').cellStyle!.numberFormat.formatCode, '000000');
      expect(cell('B2').value, TextCellValue('0000000123'));
      expect(cell('B4').value, TextCellValue('0000000000'));
      expect(cell('C2').value, IntCellValue(2));
      expect(cell('C2').cellStyle!.numberFormat.formatCode, '0000');
      expect(cell('C3').value, isNull);
      expect(cell('D3').value, TextCellValue('P'));
      expect(cell('E4').value, IntCellValue(0));
      expect(cell('E4').cellStyle!.numberFormat.formatCode, '0');
      expect((cell('E5').value as FormulaCellValue).formula, 'SUM(E2:E4)');
      expect((cell('E5').value as FormulaCellValue).cachedValue, '26');
      expect(cell('A4').cellStyle!.numberFormat.format(0), '000000');
      expect(cell('C2').cellStyle!.numberFormat.format(2), '0002');
      expect(sheet.evaluate(CellIndex.indexByString('E5')), IntCellValue(26));
    },
  );
  test('empty export has zero total without circular reference', () {
    final book = Excel.decodeBytes(CsvExportService().buildInventoryXlsx([]));
    expect(
      book['Inventory'].cell(CellIndex.indexByString('E2')).value,
      IntCellValue(0),
    );
  });
}
