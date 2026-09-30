import 'dart:convert';
import 'dart:typed_data';
import 'package:excel_plus/excel_plus.dart' as xlsx;
import 'package:flutter/material.dart';
import 'package:inventory_count_flutter_app/domain/entities/barcode.dart';
import 'package:inventory_count_flutter_app/domain/entities/asset_scan.dart';
import 'package:file_saver/file_saver.dart';

class CsvExportService {
  /// Exports inventory with copyable batch codes and numeric quantities.
  Future<void> exportToXlsx(List<ItemBox> items) async {
    await FileSaver.instance.saveAs(
      name: 'inventory_export_${_timestamp()}',
      fileExtension: 'xlsx',
      bytes: buildInventoryXlsx(items),
      mimeType: MimeType.microsoftExcel,
    );
  }

  Uint8List buildInventoryXlsx(List<ItemBox> items) {
    final book = xlsx.Excel.createExcel();
    book.rename('Sheet1', 'Inventory');
    final sheet = book['Inventory'];
    final headers = [
      'Material',
      'Batch No',
      'Serial No',
      'Pallet/Box',
      'Quantity',
    ];
    final formats = ['000000', 'General', '0000', 'General', '0'];
    for (var column = 0; column < headers.length; column++) {
      sheet.updateCell(
        xlsx.CellIndex.indexByColumnRow(columnIndex: column, rowIndex: 0),
        xlsx.TextCellValue(headers[column]),
        cellStyle: xlsx.CellStyle(bold: true),
      );
      sheet.setColumnWidth(column, column == 1 ? 18 : 14);
    }
    for (var row = 0; row < items.length; row++) {
      final item = items[row];
      final values = <xlsx.CellValue?>[
        _numericIdentifier(item.matnr),
        // Leading zeros must be in the stored value, not only its display format.
        xlsx.TextCellValue(item.batchNo),
        item.isPallet ? null : _numericIdentifier(item.serialNo),
        xlsx.TextCellValue(item.isPallet ? 'P' : 'B'),
        xlsx.IntCellValue(item.qty),
      ];
      for (var column = 0; column < values.length; column++) {
        sheet.updateCell(
          xlsx.CellIndex.indexByColumnRow(
            columnIndex: column,
            rowIndex: row + 1,
          ),
          values[column],
          cellStyle: xlsx.CellStyle(
            numberFormat: xlsx.NumFormat.custom(formatCode: formats[column]),
          ),
        );
      }
    }
    final totalRow = items.length + 2;
    sheet.updateCell(
      xlsx.CellIndex.indexByString('D$totalRow'),
      xlsx.TextCellValue('Total'),
      cellStyle: xlsx.CellStyle(bold: true),
    );
    sheet.updateCell(
      xlsx.CellIndex.indexByString('E$totalRow'),
      items.isEmpty
          ? xlsx.IntCellValue(0)
          : xlsx.FormulaCellValue('SUM(E2:E${totalRow - 1})'),
      cellStyle: xlsx.CellStyle(
        bold: true,
        numberFormat: xlsx.NumFormat.custom(formatCode: '0'),
      ),
    );
    book.recalculate();
    return Uint8List.fromList(book.encode()!);
  }

  xlsx.CellValue? _numericIdentifier(String value) {
    if (value.isEmpty) return null;
    // Preserve unexpected non-numeric identifiers instead of losing their data.
    final number = int.tryParse(value);
    return number == null
        ? xlsx.TextCellValue(value)
        : xlsx.IntCellValue(number);
  }

  /// Exports asset scan data to a CSV and saves it to local storage.
  Future<void> exportAssetScansToCsv(List<AssetScan> items) async {
    final StringBuffer buffer = StringBuffer();

    buffer.writeln('ASSET SCANS');
    buffer.writeln('Barcode,ScannedAt');
    for (final asset in items) {
      buffer.writeln(
        '${_escapeCsv(asset.barcode)},${asset.scannedAt.toIso8601String()}',
      );
    }

    await _shareAsCsv(buffer.toString(), 'asset_export_${_timestamp()}');
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<void> _shareAsCsv(String csvContent, String fileName) async {
    // Add UTF-8 BOM for Excel compatibility
    final List<int> bom = [0xEF, 0xBB, 0xBF];
    final List<int> bytes = utf8.encode(csvContent);
    final Uint8List fileBytes = Uint8List.fromList(bom + bytes);

    try {
      await FileSaver.instance.saveAs(
        name: fileName,
        fileExtension: 'csv',
        bytes: fileBytes,
        mimeType: MimeType.csv,
      );
      debugPrint('[CsvExportService] Saved to local storage: $fileName.csv');
    } catch (e) {
      debugPrint('[CsvExportService] Error saving file: $e');
      rethrow;
    }
  }

  String _timestamp() =>
      DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;

  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
