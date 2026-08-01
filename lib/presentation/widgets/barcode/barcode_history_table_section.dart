import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/barcode/barcode_bloc.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/barcode/barcode_state.dart';
import 'package:inventory_count_flutter_app/l10n/app_localizations.dart';

import '../../../core/resources/responsive_utils.dart';

class BarcodeHistoryTableSection extends StatelessWidget {
  const BarcodeHistoryTableSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BarcodeBloc, BarcodeState>(
      buildWhen: (previous, current) => previous.itemBoxes != current.itemBoxes,
      builder: (context, state) {
        final Map<String, int> groupedCounts = <String, int>{};
        final Map<String, bool> barcodeSentStatus = <String, bool>{};
        for (final itemBox in state.itemBoxes) {
          groupedCounts.update(
            itemBox.barCodeNo,
            (int currentCount) => currentCount + 1,
            ifAbsent: () => 1,
          );
          barcodeSentStatus[itemBox.barCodeNo] = itemBox.isSent;
        }

        final List<String> sortedBarcodes = groupedCounts.keys.toList()
          ..sort((a, b) => a.compareTo(b));
        final List<ScanItemRow> rows = <ScanItemRow>[];
        int nextRowNo = 1;
        for (final String barcode in sortedBarcodes) {
          final int count = groupedCounts[barcode] ?? 0;
          final bool isSent = barcodeSentStatus[barcode] ?? false;
          for (int i = 1; i <= count; i++) {
            rows.add(
              ScanItemRow(
                rowNo: nextRowNo,
                fullBarcode: i == 1 ? barcode : '',
                isSent: i == 1 ? isSent : null,
              ),
            );
            nextRowNo++;
          }
        }

        final TextStyle emptyStateStyle = TextStyle(
          fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
          fontWeight: FontWeight.w800,
        );
        final TextStyle columnHeaderStyle = TextStyle(
          fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
          fontWeight: FontWeight.w900,
        );
        final TextStyle noCellStyle = TextStyle(
          fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
          fontWeight: FontWeight.w900,
        );
        final TextStyle barcodeCellStyle = TextStyle(
          fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
          fontWeight: FontWeight.w800,
        );

        if (rows.isEmpty) {
          return Text(
            AppLocalizations.of(context)!.noScannedBarcodesYet,
            style: emptyStateStyle,
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    horizontalMargin: ResponsiveUtils.responsiveSpacing(
                      context,
                      20,
                    ),
                    columnSpacing: ResponsiveUtils.responsiveSpacing(context, 32),
                    headingRowHeight: ResponsiveUtils.responsiveSpacing(
                      context,
                      56,
                    ),
                    dataRowMinHeight: ResponsiveUtils.responsiveSpacing(
                      context,
                      54,
                    ),
                    dataRowMaxHeight: ResponsiveUtils.responsiveSpacing(
                      context,
                      62,
                    ),
                    dividerThickness: 1.2,
                    columns: <DataColumn>[
                      DataColumn(
                        label: Text(
                          AppLocalizations.of(context)!.columnNo,
                          style: columnHeaderStyle,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          AppLocalizations.of(context)!.columnBarcodeFull,
                          style: columnHeaderStyle,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          AppLocalizations.of(context)!.columnSent,
                          style: columnHeaderStyle,
                        ),
                      ),
                    ],
                    rows: rows
                        .map(
                          (row) => DataRow(
                            cells: <DataCell>[
                              DataCell(
                                Text(
                                  row.rowNo.toString(),
                                  style: noCellStyle,
                                ),
                              ),
                              DataCell(
                                Text(
                                  row.fullBarcode,
                                  style: barcodeCellStyle,
                                ),
                              ),
                              DataCell(
                                Text(
                                  row.isSent == null ? '' : (row.isSent! ? '1' : '0'),
                                  style: barcodeCellStyle.copyWith(
                                    color: row.isSent == null ? Colors.transparent : (row.isSent! ? Colors.green : Colors.red),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class ScanItemRow {
  final int rowNo;
  final String fullBarcode;
  final bool? isSent;

  const ScanItemRow({
    required this.rowNo,
    required this.fullBarcode,
    this.isSent,
  });
}
