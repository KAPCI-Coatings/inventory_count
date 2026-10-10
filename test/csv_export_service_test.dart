import 'package:flutter_test/flutter_test.dart';
import 'package:excel_plus/excel_plus.dart';
import 'package:inventory_count_flutter_app/core/services/csv_export_service.dart';
import 'package:inventory_count_flutter_app/domain/entities/barcode.dart';

void main() {
  test(
    'Excel adds numeric pallet groups in A before material without moving quantity total',
    () {
      final sheet = Excel.decodeBytes(
        CsvExportService().buildInventoryXlsx(const [
          ItemBox(isPallet: true, qty: 25, exportPalletNo: 1),
          ItemBox(qty: 1, exportPalletNo: 2),
          ItemBox(qty: 1, exportPalletNo: 2),
          ItemBox(qty: 1),
        ]),
      )['Inventory'];
      Data cell(String ref) => sheet.cell(CellIndex.indexByString(ref));
      expect(cell('A1').value, TextCellValue('Pallet Number'));
      expect(cell('B1').value, TextCellValue('Material'));
      expect(cell('A2').value, IntCellValue(1));
      expect(cell('A3').value, IntCellValue(2));
      expect(cell('A4').value, IntCellValue(2));
      expect(cell('A5').value, isNull);
      expect(cell('A6').value, isNull);
      expect(cell('A2').cellStyle!.numberFormat.formatCode, '0');
      expect(sheet.evaluate(CellIndex.indexByString('F6')), IntCellValue(28));
    },
  );
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
      expect(cell('A2').value, isNull);
      expect(cell('B2').value, IntCellValue(1234));
      expect(cell('B2').cellStyle!.numberFormat.formatCode, '000000');
      expect(cell('C2').value, TextCellValue('0000000123'));
      expect(cell('C4').value, TextCellValue('0000000000'));
      expect(cell('D2').value, IntCellValue(2));
      expect(cell('D2').cellStyle!.numberFormat.formatCode, '0000');
      expect(cell('D3').value, isNull);
      expect(cell('E3').value, TextCellValue('P'));
      expect(cell('F4').value, IntCellValue(0));
      expect(cell('F4').cellStyle!.numberFormat.formatCode, '0');
      expect((cell('F5').value as FormulaCellValue).formula, 'SUM(F2:F4)');
      expect((cell('F5').value as FormulaCellValue).cachedValue, '26');
      expect(cell('B4').cellStyle!.numberFormat.format(0), '000000');
      expect(cell('D2').cellStyle!.numberFormat.format(2), '0002');
      expect(sheet.evaluate(CellIndex.indexByString('F5')), IntCellValue(26));
    },
  );
  test('empty export has zero total without circular reference', () {
    final book = Excel.decodeBytes(CsvExportService().buildInventoryXlsx([]));
    expect(
      book['Inventory'].cell(CellIndex.indexByString('F2')).value,
      IntCellValue(0),
    );
  });
}
