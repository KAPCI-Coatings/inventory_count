import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:inventory_count_flutter_app/domain/entities/barcode.dart';
import 'package:inventory_count_flutter_app/domain/entities/asset_scan.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:share_plus/share_plus.dart';

const String _exportEmail = 'aminmohamedkhames@gmail.com';

class CsvExportService {
  /// Exports inventory barcode data to a CSV and shares it via the native
  /// share sheet (user can pick Gmail or any email app).
  Future<void> exportToCsv(List<ItemBox> items) async {
    final StringBuffer buffer = StringBuffer();

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

    buffer.writeln();

    // --- Table 2: Pallet Data ---
    buffer.writeln('PALLET DATA');
    buffer.writeln('Barcode,Material,Batch No,Serial No,Pallet/Box,Quantity');
    for (final pallet in pallets) {
      buffer.writeln(
        '${_escapeCsv(pallet.barCodeNo)},${_escapeCsv(pallet.matnr)},${_escapeCsv(pallet.batchNo)},${_escapeCsv(pallet.serialNo)},${_escapeCsv(pallet.palletBox)},${pallet.qty}',
      );
    }

    await _shareAsCsv(
      buffer.toString(),
      'inventory_export_${_timestamp()}',
    );
  }

  /// Exports asset scan data to a CSV and shares it via the native share sheet.
  Future<void> exportAssetScansToCsv(List<AssetScan> items) async {
    final StringBuffer buffer = StringBuffer();

    buffer.writeln('ASSET SCANS');
    buffer.writeln('Barcode,ScannedAt');
    for (final asset in items) {
      buffer.writeln(
        '${_escapeCsv(asset.barcode)},${asset.scannedAt.toIso8601String()}',
      );
    }

    await _shareAsCsv(
      buffer.toString(),
      'asset_export_${_timestamp()}',
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<void> _shareAsCsv(String csvContent, String fileName) async {
    // Add UTF-8 BOM for Excel compatibility
    final List<int> bom = [0xEF, 0xBB, 0xBF];
    final List<int> bytes = utf8.encode(csvContent);
    final Uint8List fileBytes = Uint8List.fromList(bom + bytes);

    // Write to a temporary file so email client can attach it
    final Directory tempDir = await getTemporaryDirectory();
    final File tempFile = File('${tempDir.path}/$fileName.csv');
    await tempFile.writeAsBytes(fileBytes);

    final Email email = Email(
      body: 'بيانات تصدير ملفات الجرد مرفقة في هذا الإيميل.',
      subject: 'INC Export — $fileName',
      recipients: [_exportEmail],
      attachmentPaths: [tempFile.path],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
    } catch (e) {
      debugPrint('[CsvExportService] FlutterEmailSender failed, falling back to Share: $e');
      final XFile xFile = XFile(tempFile.path, mimeType: 'text/csv');
      await Share.shareXFiles(
        [xFile],
        subject: 'INC Export — $fileName',
        text: 'إرسال إلى: $_exportEmail',
      );
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
