import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_count_flutter_app/core/resources/responsive_utils.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/scanner/scanner_bloc.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/scanner/scanner_state.dart';

class ScannerStatusSection extends StatelessWidget {
  const ScannerStatusSection({super.key});

  @override
  Widget build(BuildContext context) {
    final double baseFontSize = ResponsiveUtils.responsiveFontSize(context, 20);
    final double spacing = ResponsiveUtils.responsiveSpacing(context, 4);

    final TextStyle style =
        (Theme.of(context).textTheme.bodyLarge ?? const TextStyle()).copyWith(
          fontSize: baseFontSize,
          fontWeight: FontWeight.w800,
        );

    return BlocBuilder<ScannerBloc, ScannerState>(
      builder: (context, state) {
        final String material = state.lastScan?.matnr ?? '-';
        final String batch = state.lastScan?.batchNo ?? '-';
        final String serial = state.lastScan?.serialNo ?? '-';
        final String palletBox = state.lastScan?.palletBox ?? '-';
        final int qty = state.lastScan?.qty ?? 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height: spacing),
            _InfoRow(label: 'Material', value: material, style: style),
            SizedBox(height: spacing),
            _InfoRow(label: 'Batch No', value: batch, style: style),
            SizedBox(height: spacing),
            _InfoRow(label: 'Serial No', value: serial, style: style),
            SizedBox(height: spacing),
            _InfoRow(label: 'Qty', value: qty.toString(), style: style),
            SizedBox(height: spacing),
            _InfoRow(label: 'Pallet Box', value: palletBox, style: style),
            SizedBox(height: spacing),
            const Divider(thickness: 2, color: Colors.black),
            SizedBox(height: spacing),
            _InfoRow(
              label: 'Pallet Box Count',
              value: state.palletBoxCount.toString(),
              style: style,
            ),
            SizedBox(height: spacing),
            const Divider(thickness: 2, color: Colors.black),
            SizedBox(height: spacing),
            _InfoRow(
              label: 'Box Count',
              value: state.boxCount.toString(),
              style: style,
            ),
            SizedBox(height: spacing),
            _InfoRow(
              label: 'Pallet Count',
              value: state.palletCount == 0 ? '-' : state.palletCount.toString(),
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
