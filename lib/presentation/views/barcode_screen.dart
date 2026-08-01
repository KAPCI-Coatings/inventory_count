import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/barcode/barcode_bloc.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/barcode/barcode_event.dart';
import 'package:inventory_count_flutter_app/presentation/widgets/barcode/barcode_actions_section.dart';
import 'package:inventory_count_flutter_app/presentation/widgets/barcode/barcode_status_section.dart';
import 'package:inventory_count_flutter_app/core/widgets/error_popup.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/barcode/barcode_state.dart';
import 'package:inventory_count_flutter_app/l10n/app_localizations.dart';
import '../../core/resources/responsive_utils.dart';
import '../widgets/barcode/barcode_app_bar.dart';

class BarcodeScreen extends StatefulWidget {
  const BarcodeScreen({super.key});

  @override
  State<BarcodeScreen> createState() => _BarcodeScreenState();
}

class _BarcodeScreenState extends State<BarcodeScreen> {
  BarcodeBloc? _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<BarcodeBloc>();
    _bloc!
      ..add(BarcodeInitializeRequested())
      ..add(BarcodeScannerEnableRequested());
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Translates a short error key (used in BLoC state) into a human-readable,
  /// localised string. Falls back to the key itself if unknown.
  String _translate(BuildContext context, String key, {String? details}) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return key;

    switch (key) {
      // Barcode errors
      case 'invalid_barcode_length':
        return l10n.error_invalid_barcode_format;
      case 'invalid_pallet_prefix':
        return l10n.error_invalid_barcode_format;
      case 'error_unexpected_scan':
        return l10n.error_unexpected_scan;
      case 'error_scan_failed':
        return l10n.error_scan_failed;

      // Duplicate warning
      case 'warning_duplicate_barcode':
        return l10n.error_duplicate_barcode;
      case 'error_box_duplicate':
        return 'لايمكن قرائه الصندوق مرتين';

      // Network / post errors
      case 'error_no_scanned_data':
        return l10n.error_no_scanned_data;
      case 'error_invalid_url':
        return l10n.error_invalid_url;
      case 'error_post_no_connection':
        return l10n.error_post_no_connection;
      case 'error_post_http_not_allowed':
        return l10n.error_post_http_not_allowed;
      case 'error_post_server_code':
        return l10n.error_post_server_code(details ?? '');
      case 'error_post_unknown':
        return l10n.error_post_unknown(details ?? '');
      case 'error_post_server_connection':
        return l10n.error_post_server_connection(details ?? '');

      // Success
      case 'success_post_clear_cache':
        return l10n.success_post_clear_cache;

      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BarcodeAppBar(),
      body: FocusScope(
        canRequestFocus: false,
        child: SafeArea(
          child: Builder(
            builder: (context) {
            final double pagePadding = ResponsiveUtils.responsiveSpacing(
              context,
              16,
            );

            return BlocListener<BarcodeBloc, BarcodeState>(
              listener: (context, state) {
                // ── Warning (duplicate) — popup with Yes/No ──
                if (state.status == BarcodeStatus.warning &&
                    state.centeredWarningMessage != null &&
                    state.centeredWarningMessage!.isNotEmpty) {

                  const String confirmMessage = 'هل تريد تكرار هذا الباركود\nنعم او لا';

                  ErrorPopup.showWarning(context, confirmMessage).then((confirmed) {
                    if (!context.mounted) return;
                    if (confirmed == true) {
                      context.read<BarcodeBloc>().add(BarcodeDuplicateConfirmed());
                    } else {
                      context.read<BarcodeBloc>().add(BarcodeDuplicateRejected());
                    }
                    context.read<BarcodeBloc>().add(BarcodeDismissCenteredMessageRequested());
                  });
                  return;
                }

                // ── Error — red popup ─────────────────────────────────────────
                if (state.status == BarcodeStatus.error) {
                  if (state.centeredErrorMessage != null &&
                      state.centeredErrorMessage!.isNotEmpty) {
                    ErrorPopup.show(
                      context,
                      _translate(context, state.centeredErrorMessage!),
                      variant: PopupVariant.error,
                      onRetry: () {
                        context.read<BarcodeBloc>().add(
                          BarcodeScannerEnableRequested(),
                        );
                      },
                    ).then((_) {
                      if (!context.mounted) return;
                      context.read<BarcodeBloc>().add(BarcodeDismissCenteredMessageRequested());
                    });
                  }
                  return;
                }

                // ── Success / Send result ─────────────────────────────────────
                if (state.status == BarcodeStatus.success &&
                    state.centeredSuccessMessage != null &&
                    state.centeredSuccessMessage!.isNotEmpty) {
                  ErrorPopup.show(
                    context,
                    _translate(context, state.centeredSuccessMessage!),
                    variant: PopupVariant.success,
                  ).then((_) {
                    if (!context.mounted) return;
                    context.read<BarcodeBloc>().add(BarcodeDismissCenteredMessageRequested());
                  });
                }
              },
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(pagePadding),
                    child: Column(
                      children: <Widget>[
                        const BarcodeStatusSection(),
                        const Spacer(),
                        const BarcodeActionsSection(),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ),
  );
}
}
