import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:inventory_count_flutter_app/domain/entities/barcode.dart';
import 'package:inventory_count_flutter_app/core/resources/responsive_utils.dart';
import 'package:inventory_count_flutter_app/l10n/app_localizations.dart';

class SearchResultsTable extends StatefulWidget {
  final List<ItemBox> items;
  final int totalQty;

  const SearchResultsTable({
    super.key,
    required this.items,
    required this.totalQty,
  });

  @override
  State<SearchResultsTable> createState() => _SearchResultsTableState();
}

class _SearchResultsTableState extends State<SearchResultsTable> {
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();

  static const int _flexPalletNo = 85;
  static const int _flexMaterial = 85;
  static const int _flexBatch = 110;
  static const int _flexSerial = 80;
  static const int _flexPalletBox = 70;
  static const int _flexQty = 65;
  static const double _minTableWidth = 500.0;

  @override
  void dispose() {
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.blueGrey.shade800, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double tableWidth = math.max(
              constraints.maxWidth,
              _minTableWidth,
            );

            return Scrollbar(
              controller: _horizontalScrollController,
              thumbVisibility: true,
              notificationPredicate: (notification) =>
                  notification.depth == 0 ||
                  notification.metrics.axis == Axis.horizontal,
              child: SingleChildScrollView(
                controller: _horizontalScrollController,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth,
                  child: Column(
                    children: [
                      // Header Row
                      _buildHeaderRow(context),
                      Divider(
                        color: Colors.blueGrey.shade800,
                        thickness: 2,
                        height: 0,
                      ),
                      // Data Rows
                      Expanded(
                        child: widget.items.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    '— ${AppLocalizations.of(context)!.noScannedBarcodesYet} —',
                                    style: TextStyle(
                                      fontSize:
                                          ResponsiveUtils.responsiveFontSize(
                                            context,
                                            14,
                                          ),
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              )
                            : Scrollbar(
                                controller: _verticalScrollController,
                                thumbVisibility: true,
                                child: ListView.separated(
                                  controller: _verticalScrollController,
                                  itemCount: widget.items.length,
                                  separatorBuilder: (context, index) =>
                                      const Divider(
                                        color: Colors.grey,
                                        thickness: 1,
                                        height: 0,
                                      ),
                                  itemBuilder: (context, index) {
                                    final item = widget.items[index];
                                    return _buildDataRow(context, item, index);
                                  },
                                ),
                              ),
                      ),
                      Divider(
                        color: Colors.blueGrey.shade800,
                        thickness: 2,
                        height: 0,
                      ),
                      // Total Row (Original styling)
                      Container(
                        color: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        alignment: Alignment.center,
                        child: Text(
                          '${AppLocalizations.of(context)!.totalQty} : ${widget.totalQty}',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.responsiveFontSize(
                              context,
                              16,
                            ),
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final l10n = AppLocalizations.of(context)!;

    final String colPalletNo = isArabic ? 'رقم البالتة' : 'Pallet No';
    final String colMaterial = isArabic ? l10n.material : 'Material';
    final String colBatch = isArabic ? l10n.batchNo : 'Batch No';
    final String colSerial = isArabic ? l10n.serialNo : 'Serial No';
    final String colPalletBox = isArabic ? 'باليتة/صندوق' : 'Pallet/Box';
    final String colQty = isArabic ? l10n.qty : 'Quantity';

    return Container(
      color: Colors.blueGrey.shade800,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeaderCell(colPalletNo, _flexPalletNo),
            _buildHeaderDivider(),
            _buildHeaderCell(colMaterial, _flexMaterial),
            _buildHeaderDivider(),
            _buildHeaderCell(colBatch, _flexBatch),
            _buildHeaderDivider(),
            _buildHeaderCell(colSerial, _flexSerial),
            _buildHeaderDivider(),
            _buildHeaderCell(colPalletBox, _flexPalletBox),
            _buildHeaderDivider(),
            _buildHeaderCell(colQty, _flexQty),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String label, int flex) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildHeaderDivider() {
    return Container(width: 1, color: Colors.blueGrey.shade900);
  }

  Widget _buildDataRow(BuildContext context, ItemBox item, int index) {
    final bgColor = index % 2 == 0 ? Colors.white : Colors.grey.shade100;

    final String palletNo =
        (item.exportPalletNo != null && item.exportPalletNo! > 0)
        ? item.exportPalletNo.toString()
        : (item.palletNo != null && item.palletNo! > 0
              ? item.palletNo.toString()
              : '-');
    final String material = item.matnr.isNotEmpty ? item.matnr : '-';
    final String batch = item.batchNo.isNotEmpty ? item.batchNo : '-';
    final String serial = item.isPallet
        ? '-'
        : (item.serialNo.isNotEmpty ? item.serialNo : '-');
    final String palletBox = item.isPallet ? 'P' : 'B';
    final String qty = item.qty.toString();

    return Container(
      color: bgColor,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDataCell(palletNo, _flexPalletNo),
            _buildDataDivider(),
            _buildDataCell(material, _flexMaterial, isBold: true),
            _buildDataDivider(),
            _buildDataCell(batch, _flexBatch),
            _buildDataDivider(),
            _buildDataCell(serial, _flexSerial),
            _buildDataDivider(),
            _buildDataCell(palletBox, _flexPalletBox),
            _buildDataDivider(),
            _buildDataCell(qty, _flexQty, isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCell(String text, int flex, {bool isBold = false}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 2),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildDataDivider() {
    return Container(width: 1, color: Colors.grey.shade400);
  }
}
