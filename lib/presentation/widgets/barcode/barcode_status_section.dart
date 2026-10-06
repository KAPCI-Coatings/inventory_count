import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_count_flutter_app/core/resources/responsive_utils.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/barcode/barcode_bloc.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/barcode/barcode_event.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/barcode/barcode_state.dart';
import 'package:inventory_count_flutter_app/l10n/app_localizations.dart';

class BarcodeStatusSection extends StatelessWidget {
  final bool compact;
  final bool fillAvailableHeight;

  const BarcodeStatusSection({
    super.key,
    this.compact = false,
    this.fillAvailableHeight = false,
  });

  @override
  Widget build(BuildContext context) {
    final double baseFontSize = compact
        ? 16
        : ResponsiveUtils.responsiveFontSize(context, 20);
    final double spacing = compact
        ? 1
        : ResponsiveUtils.responsiveSpacing(context, 4);

    final TextStyle style =
        (Theme.of(context).textTheme.bodyLarge ?? const TextStyle()).copyWith(
          fontSize: baseFontSize,
          fontWeight: FontWeight.w800,
          height: compact ? 1.2 : null,
        );

    return BlocBuilder<BarcodeBloc, BarcodeState>(
      builder: (context, state) {
        final lastScan = state.lastScan;
        final String material = lastScan?.matnr.isNotEmpty == true
            ? lastScan!.matnr
            : '-';
        final String batch = lastScan?.batchNo.isNotEmpty == true
            ? lastScan!.batchNo
            : '-';
        final String serial = lastScan?.serialNo.isNotEmpty == true
            ? lastScan!.serialNo
            : '-';
        final String palletBox = lastScan?.palletBox.isNotEmpty == true
            ? lastScan!.palletBox
            : '-';
        final int qty = lastScan?.qty ?? 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: fillAvailableHeight ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: fillAvailableHeight
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: spacing),
            _InfoRow(
              label: AppLocalizations.of(context)!.material,
              value: material,
              style: style,
            ),
            SizedBox(height: spacing),
            _InfoRow(
              label: AppLocalizations.of(context)!.batchNo,
              value: batch,
              style: style,
            ),
            SizedBox(height: spacing),
            _InfoRow(
              label: AppLocalizations.of(context)!.serialNo,
              value: serial,
              style: style,
            ),
            SizedBox(height: spacing),
            _InfoRow(
              label: AppLocalizations.of(context)!.qty,
              value: qty.toString(),
              style: style,
            ),
            SizedBox(height: spacing),
            _InfoRow(
              label: AppLocalizations.of(context)!.palletBox,
              value: palletBox,
              style: style,
            ),
            SizedBox(height: spacing),
            Divider(height: compact ? 6 : 16, thickness: 2, color: Colors.black),
            SizedBox(height: spacing),
            _InfoRow(
              label: AppLocalizations.of(context)!.palletBoxCount,
              value: state.palletBoxCount.toString(),
              style: style,
            ),
            SizedBox(height: spacing),
            Divider(height: compact ? 6 : 16, thickness: 2, color: Colors.black),
            SizedBox(height: spacing),
            _InfoRow(
              label: AppLocalizations.of(context)!.boxCount,
              value: state.boxCount.toString(),
              style: style,
            ),
            SizedBox(height: spacing),
            _InfoRow(
              label: AppLocalizations.of(context)!.palletCount,
              value: state.palletCount.toString(),
              style: style,
            ),
            Divider(height: compact ? 6 : 16, thickness: 2, color: Colors.black),
            RadioGroup<ScanType>(
              groupValue: state.scanType,
              onChanged: (value) {
                if (value != null) {
                  context.read<BarcodeBloc>().add(
                    BarcodeScanTypeChanged(value),
                  );
                }
              },
              child: Row(
                children: [
                  Expanded(
                    child: RadioListTile<ScanType>(
                      value: ScanType.pallet,
                      title: Text(AppLocalizations.of(context)!.scanPallets),
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minVerticalPadding: 0,
                      minTileHeight: 32,
                      dense: true,
                      enabled:
                          !state.isSending &&
                          state.status != BarcodeStatus.warning,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<ScanType>(
                      value: ScanType.box,
                      title: Text(AppLocalizations.of(context)!.scanBoxes),
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minVerticalPadding: 0,
                      minTileHeight: 32,
                      dense: true,
                      enabled:
                          !state.isSending &&
                          state.status != BarcodeStatus.warning,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? style;

  const _InfoRow({required this.label, required this.value, this.style});

  @override
  Widget build(BuildContext context) {
    return Text('$label : $value', style: style);
  }
}
