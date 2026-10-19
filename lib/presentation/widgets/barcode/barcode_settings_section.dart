import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/barcode/barcode_bloc.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/barcode/barcode_event.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/barcode/barcode_state.dart';
import 'package:inventory_count_flutter_app/l10n/app_localizations.dart';



class BarcodeSettingsSection extends StatelessWidget {
  const BarcodeSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final ButtonStyle simpleButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.grey.shade400,
      foregroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
      minimumSize: const Size(180, 56),
      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      elevation: 0,
    );

    return BlocBuilder<BarcodeBloc, BarcodeState>(
      builder: (context, state) {
        final bool isPosting = state.status == BarcodeStatus.posting;

        return Column(
          children: <Widget>[
            const SizedBox(height: 48),
            Text(AppLocalizations.of(context)!.numberOfScan, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(state.dailyScanCount.toString(), style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 20),
            ElevatedButton(
              style: simpleButtonStyle,
              onPressed: isPosting
                  ? null
                  : () => context.read<BarcodeBloc>().add(BarcodePostCurrentOrderRequested()),
              child: isPosting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : Text(AppLocalizations.of(context)!.post),
            ),
          ],
        );
      },
    );
  }
}
