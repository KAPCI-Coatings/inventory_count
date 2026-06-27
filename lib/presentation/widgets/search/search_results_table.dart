import 'package:flutter/material.dart';
import 'package:inventory_count_flutter_app/domain/entities/item_box.dart';
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
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getGroupedItems() {
    final Map<String, int> grouped = {};
    for (var item in widget.items) {
      final batch = item.batchNo.isEmpty ? 'N/A' : item.batchNo;
      grouped[batch] = (grouped[batch] ?? 0) + item.qty;
    }

    final List<Map<String, dynamic>> result = grouped.entries
        .map((e) => {'batchNo': e.key, 'qty': e.value})
        .toList();

    result.sort(
      (a, b) => (a['batchNo'] as String).compareTo(b['batchNo'] as String),
    );
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final groupedItems = _getGroupedItems();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        borderRadius: BorderRadius.circular(10),
        child: Column(
          children: [
            // Header Row
            _buildHeaderRow(context),
            // Divider
            Divider(color: Colors.blueGrey.shade800, thickness: 2, height: 0),
            // Items List
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                trackVisibility: true,
                thickness: 8,
                radius: const Radius.circular(4),
                child: ListView.separated(
                  controller: _scrollController,
                  itemCount: groupedItems.length,
                  separatorBuilder: (context, index) => const Divider(
                    color: Colors.grey,
                    thickness: 1,
                    height: 0,
                  ),
                  itemBuilder: (context, index) {
                    final item = groupedItems[index];
                    return _buildDataRow(
                      context,
                      item['qty'].toString(),
                      item['batchNo'] as String,
                      index,
                    );
                  },
                ),
              ),
            ),
            // Divider
            Divider(color: Colors.blueGrey.shade800, thickness: 2, height: 0),
            // Total Row
            Container(
              color: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(vertical: 6),
              alignment: Alignment.center,
              child: Text(
                '${AppLocalizations.of(context)!.totalQty} : ${widget.totalQty}',
                style: TextStyle(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.blueGrey.shade800,
              padding: const EdgeInsets.symmetric(vertical: 8),
              alignment: Alignment.center,
              child: Text(
                AppLocalizations.of(context)!.qty,
                style: TextStyle(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Container(width: 2, color: Colors.blueGrey.shade800),
          Expanded(
            flex: 5,
            child: Container(
              color: Colors.blueGrey.shade800,
              padding: const EdgeInsets.symmetric(vertical: 8),
              alignment: Alignment.center,
              child: Text(
                AppLocalizations.of(context)!.patch,
                style: TextStyle(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(
    BuildContext context,
    String qty,
    String patch,
    int index,
  ) {
    final bgColor = index % 2 == 0 ? Colors.white : Colors.grey.shade100;
    return IntrinsicHeight(
      child: Container(
        color: bgColor,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                alignment: Alignment.center,
                child: Text(
                  qty,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Container(width: 1, color: Colors.grey.shade400),
            Expanded(
              flex: 5,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                alignment: Alignment.center,
                child: Text(
                  patch,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
