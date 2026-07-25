import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_count_flutter_app/core/widgets/default_button.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/auth/auth_bloc.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/auth/auth_event.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/auth/auth_state.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/barcode/barcode_bloc.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/barcode/barcode_event.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/barcode/barcode_state.dart';
import 'package:inventory_count_flutter_app/core/di/di.dart';
import 'package:inventory_count_flutter_app/core/services/csv_export_service.dart';
import 'package:inventory_count_flutter_app/domain/repositories/barcode_repository.dart';
import 'package:inventory_count_flutter_app/l10n/app_localizations.dart';

import '../../../../../core/resources/responsive_utils.dart';
import '../../../../../core/routes_manger/routes.dart';

class BarcodeActionsSection extends StatefulWidget {
  const BarcodeActionsSection({super.key});

  @override
  State<BarcodeActionsSection> createState() => _BarcodeActionsSectionState();
}

class _BarcodeActionsSectionState extends State<BarcodeActionsSection> {
  bool _isExporting = false;
  bool _isNavigating = false;

  void _navigateToRoute(String routeName) {
    if (_isNavigating) return;
    _isNavigating = true;
    Navigator.of(context).pushNamed(routeName).then((_) {
      if (mounted) {
        _isNavigating = false;
      }
    });
  }

  Future<void> _showClearConfirmation(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          l10n?.clear ?? 'Clear',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          l10n?.confirm_clear_screen ?? 'Reset the screen? Scanned data will remain saved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n?.no ?? 'No'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black87),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n?.yes ?? 'Yes',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<BarcodeBloc>().add(BarcodeNewOrderRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final double gap = ResponsiveUtils.responsiveSpacing(context, 8);
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final bool isUser = authState.selectedRole.toLowerCase() == 'user';

        if (isUser) {
          return Center(
            child: DefaultButton(
              text: AppLocalizations.of(context)!.exit,
              onPressed: () {
                context.read<AuthBloc>().add(const AuthLogoutRequested());
                Navigator.of(context).pushReplacementNamed(Routes.login);
              },
              backgroundColor: Colors.grey.shade400,
              textColor: Colors.black,
              textSize: ResponsiveUtils.responsiveFontSize(context, 16),
              width: ResponsiveUtils.responsiveWidth(context, 0.4),
              height: ResponsiveUtils.responsiveHeight(
                context,
                0.07,
              ).clamp(48, 64),
            ),
          );
        }

        return BlocBuilder<BarcodeBloc, BarcodeState>(
          buildWhen: (prev, curr) => prev.isSending != curr.isSending,
          builder: (context, barcodeState) {
            return Column(
              children: [
                Row(
                  children: <Widget>[
                    Expanded(
                      child: DefaultButton(
                        text: AppLocalizations.of(context)!.settings,
                        onPressed: () => _navigateToRoute(Routes.settings),
                        backgroundColor: Colors.grey.shade400,
                        textColor: Colors.black,
                        textSize:
                            ResponsiveUtils.responsiveFontSize(context, 16),
                      ),
                    ),
                    SizedBox(width: gap),
                    Expanded(
                      child: DefaultButton(
                        text: AppLocalizations.of(context)!.search,
                        onPressed: () => _navigateToRoute(Routes.search),
                        backgroundColor: Colors.grey.shade400,
                        textColor: Colors.black,
                        textSize:
                            ResponsiveUtils.responsiveFontSize(context, 16),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: gap),
                Row(
                  children: <Widget>[
                    // ── Send ────────────────────────────────────────────────
                    Expanded(
                      child: DefaultButton(
                        text: AppLocalizations.of(context)!.send,
                        isLoading: barcodeState.isSending,
                        onPressed: barcodeState.isSending
                            ? null
                            : () {
                                context.read<BarcodeBloc>().add(
                                  BarcodePostCurrentOrderRequested(),
                                );
                              },
                        backgroundColor: Colors.grey.shade400,
                        textColor: Colors.black,
                        textSize:
                            ResponsiveUtils.responsiveFontSize(context, 16),
                      ),
                    ),
                    SizedBox(width: gap),

                    // ── Export ───────────────────────────────────────────────
                    Expanded(
                      child: DefaultButton(
                        text: AppLocalizations.of(context)!.export,
                        isLoading: _isExporting,
                        onPressed: _isExporting
                            ? null
                            : () async {
                                setState(() => _isExporting = true);
                                try {
                                  final items = await instance<BarcodeRepository>()
                                      .getScannedItems();
                                  await instance<CsvExportService>()
                                      .exportToCsv(items);
                                } finally {
                                  if (mounted) {
                                    setState(() => _isExporting = false);
                                  }
                                }
                              },
                        backgroundColor: Colors.grey.shade400,
                        textColor: Colors.black,
                        textSize:
                            ResponsiveUtils.responsiveFontSize(context, 16),
                      ),
                    ),
                    SizedBox(width: gap),

                    // ── Clear (reset screen, keep cache) ─────────────────────
                    Expanded(
                      child: DefaultButton(
                        text: AppLocalizations.of(context)!.clear,
                        onPressed: () => _showClearConfirmation(context),
                        backgroundColor: Colors.grey.shade400,
                        textColor: Colors.black,
                        textSize:
                            ResponsiveUtils.responsiveFontSize(context, 16),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}
