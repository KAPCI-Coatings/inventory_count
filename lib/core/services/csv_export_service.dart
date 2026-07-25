import 'dart:convert';
import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';
import 'package:inventory_count_flutter_app/domain/entities/barcode.dart';
import 'package:inventory_count_flutter_app/domain/entities/asset_scan.dart';

class CsvExportService {
  /// Exports the given items to a CSV file and triggers the native share dialog.
  /// The CSV file will contain two tables: one for box data, one for pallet data.
  Future<void> exportToCsv(List<ItemBox> items) async {
    final StringBuffer buffer = StringBuffer();

    // Separate items into boxes and pallets
    final List<ItemBox> boxes = items.where((item) => !item.isPallet).toList();
    final List<ItemBox> pallets = items.where((item) => item.isPallet).toList();

    // --- Table 1: Box Data ---
    buffer.writeln('BOX DATA');
    buffer.writeln('Barcode,Material,Batch No,Serial No,Pallet/Box,Quantity');
    for (final box in boxes) {
      buffer.writeln(
        '${_escapeCsv(box.barCodeNo)},${_escapeCsv(box.matnr)},${_escapeCsv(box.batchNo)},${_escapeCsv(box.serialNo)},${_escapeCsv(box.palletBox)},${box.qty}',
      );
    }

    buffer.writeln(); // Empty line between tables

    // --- Table 2: Pallet Data ---
    buffer.writeln('PALLET DATA');
    buffer.writeln('Barcode,Material,Batch No,Serial No,Pallet/Box,Quantity');
    for (final pallet in pallets) {
      buffer.writeln(
        '${_escapeCsv(pallet.barCodeNo)},${_escapeCsv(pallet.matnr)},${_escapeCsv(pallet.batchNo)},${_escapeCsv(pallet.serialNo)},${_escapeCsv(pallet.palletBox)},${pallet.qty}',
      );
    }

    // Add UTF-8 BOM for Excel compatibility, then encode the CSV string
    final List<int> bom = [0xEF, 0xBB, 0xBF];
    final List<int> bytes = utf8.encode(buffer.toString());
    final Uint8List fileBytes = Uint8List.fromList(bom + bytes);

    // Save to device using file_saver
    await FileSaver.instance.saveAs(
      name:
          'inventory_export_${DateTime.now().toIso8601String().replaceAll(':', '-')}',
      bytes: fileBytes,
      fileExtension: 'csv',
      mimeType: MimeType.csv,
    );
  }

  Future<void> exportAssetScansToCsv(List<AssetScan> items) async {
    final StringBuffer buffer = StringBuffer();

    buffer.writeln('ASSET SCANS');
    buffer.writeln('Barcode,ScannedAt');
    for (final asset in items) {
      buffer.writeln(
        '${_escapeCsv(asset.barcode)},${asset.scannedAt.toIso8601String()}',
      );
    }

    // Add UTF-8 BOM for Excel compatibility, then encode the CSV string
    final List<int> bom = [0xEF, 0xBB, 0xBF];
    final List<int> bytes = utf8.encode(buffer.toString());
    final Uint8List fileBytes = Uint8List.fromList(bom + bytes);

    await FileSaver.instance.saveAs(
      name:
          'asset_export_${DateTime.now().toIso8601String().replaceAll(':', '-')}',
      bytes: fileBytes,
      fileExtension: 'csv',
      mimeType: MimeType.csv,
    );
  }

  /// Helper to safely escape CSV strings that might contain commas
  String _escapeCsv(String value) {
    if (value.contains(',')) {
      return '"$value"';
    }
    return value;
  }
}
