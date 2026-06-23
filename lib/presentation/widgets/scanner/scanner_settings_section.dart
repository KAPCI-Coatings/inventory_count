import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/scanner/scanner_bloc.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/scanner/scanner_event.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/scanner/scanner_state.dart';



class ScannerSettingsSection extends StatelessWidget {
  const ScannerSettingsSection({super.key});

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

    return BlocBuilder<ScannerBloc, ScannerState>(
      builder: (context, state) {
        final bool isPosting = state.status == ScannerStatus.posting;

        return Column(
          children: <Widget>[
            const SizedBox(height: 48),
            const Text('Number of Scan :', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(state.dailyScanCount.toString(), style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 20),
            ElevatedButton(
              style: simpleButtonStyle,
              onPressed: isPosting
                  ? null
                  : () => context.read<ScannerBloc>().add(ScannerPostCurrentOrderRequested()),
              child: isPosting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : const Text('Post'),
            ),
          ],
        );
      },
    );
  }
}
