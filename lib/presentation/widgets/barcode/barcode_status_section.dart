import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_count_flutter_app/core/resources/responsive_utils.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/barcode/barcode_bloc.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/barcode/barcode_state.dart';
import 'package:inventory_count_flutter_app/l10n/app_localizations.dart';

class BarcodeStatusSection extends StatelessWidget {
  const BarcodeStatusSection({super.key});

  @override
  Widget build(BuildContext context) {
    final double baseFontSize = ResponsiveUtils.responsiveFontSize(context, 20);
    final double spacing = ResponsiveUtils.responsiveSpacing(context, 4);

    final TextStyle style =
        (Theme.of(context).textTheme.bodyLarge ?? const TextStyle()).copyWith(
          fontSize: baseFontSize,
          fontWeight: FontWeight.w800,
        );

    return BlocBuilder<BarcodeBloc, BarcodeState>(
      builder: (context, state) {
        final lastScan = state.lastScan;
        final String material = lastScan?.matnr.isNotEmpty == true ? lastScan!.matnr : '-';
        final String batch = lastScan?.batchNo.isNotEmpty == true ? lastScan!.batchNo : '-';
        final String serial = lastScan?.serialNo.isNotEmpty == true ? lastScan!.serialNo : '-';
        final String palletBox = lastScan?.palletBox.isNotEmpty == true ? lastScan!.palletBox : '-';
        final int qty = lastScan?.qty ?? 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
        SizedBox(height: spacing),
        _InfoRow(label: AppLocalizations.of(context)!.material, value: material, style: style),
        SizedBox(height: spacing),
        _InfoRow(label: AppLocalizations.of(context)!.batchNo, value: batch, style: style),
        SizedBox(height: spacing),
        _InfoRow(label: AppLocalizations.of(context)!.serialNo, value: serial, style: style),
        SizedBox(height: spacing),
        _InfoRow(label: AppLocalizations.of(context)!.qty, value: qty.toString(), style: style),
        SizedBox(height: spacing),
        _InfoRow(label: AppLocalizations.of(context)!.palletBox, value: palletBox, style: style),
        SizedBox(height: spacing),
        const Divider(thickness: 2, color: Colors.black),
        SizedBox(height: spacing),
        _InfoRow(
          label: AppLocalizations.of(context)!.palletBoxCount,
          value: state.palletBoxCount.toString(),
          style: style,
        ),
        SizedBox(height: spacing),
        const Divider(thickness: 2, color: Colors.black),
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
