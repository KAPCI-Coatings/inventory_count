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
import 'package:inventory_count_flutter_app/core/widgets/scanner_dialog.dart';
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
  bool _isConfirmingPallet = false;
  bool _isNavigating = false;

  Future<void> _confirmNewPallet() async {
    if (_isConfirmingPallet) return;
    final bloc = context.read<BarcodeBloc>();
    if (!bloc.state.canChangePallet) return;
    setState(() => _isConfirmingPallet = true);
    try {
      final l10n = AppLocalizations.of(context)!;
      final confirmed = await showScannerDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.addNewPallet),
          content: Text(l10n.confirmNewPallet),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.no),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.yes),
            ),
          ],
        ),
      );
      if (confirmed == true && mounted) bloc.add(BarcodeNewPalletRequested());
    } finally {
      if (mounted) setState(() => _isConfirmingPallet = false);
    }
  }

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
    if (!context.mounted) return;
    final bool? confirmed = await showScannerDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'مسح البيانات',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('هل انت متاكد من مسح جميع البيانات من الجهاز'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('لا'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black87),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('نعم', style: TextStyle(color: Colors.white)),
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
          final double gap = ResponsiveUtils.responsiveSpacing(context, 8);
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DefaultButton(
                      text: AppLocalizations.of(context)!.search,
                      onPressed: () => _navigateToRoute(Routes.search),
                      backgroundColor: Colors.grey.shade400,
                      textColor: Colors.black,
                      textSize: ResponsiveUtils.responsiveFontSize(context, 16),
                    ),
                  ),
                  SizedBox(width: gap),
                  Expanded(
                    child: BlocBuilder<BarcodeBloc, BarcodeState>(
                      buildWhen: (p, c) => false,
                      builder: (ctx, s) => DefaultButton(
                        text: AppLocalizations.of(context)!.export,
                        onPressed: _isExporting
                            ? null
                            : () async {
                                setState(() => _isExporting = true);
                                try {
                                  final items =
                                      await instance<BarcodeRepository>()
                                          .getScannedItems();
                                  await instance<CsvExportService>()
                                      .exportToXlsx(items);
                                } finally {
                                  if (mounted) {
                                    setState(() => _isExporting = false);
                                  }
                                }
                              },
                        backgroundColor: Colors.grey.shade400,
                        textColor: Colors.black,
                        textSize: ResponsiveUtils.responsiveFontSize(
                          context,
                          16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: gap),
              Center(
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
              ),
            ],
          );
        }

        return BlocBuilder<BarcodeBloc, BarcodeState>(
          buildWhen: (prev, curr) =>
              prev.canChangePallet != curr.canChangePallet ||
              prev.isSending != curr.isSending ||
              prev.hasPendingItems != curr.hasPendingItems,
          builder: (context, barcodeState) {
            return Column(
              children: [
                Row(
                  children: <Widget>[
                    Expanded(
                      child: DefaultButton(
                        text: AppLocalizations.of(context)!.search,
                        onPressed: () => _navigateToRoute(Routes.search),
                        backgroundColor: Colors.grey.shade400,
                        textColor: Colors.black,
                        textSize: ResponsiveUtils.responsiveFontSize(
                          context,
                          16,
                        ),
                      ),
                    ),
                    SizedBox(width: gap),
                    Expanded(
                      child: DefaultButton(
                        text: AppLocalizations.of(context)!.addNewPallet,
                        onPressed:
                            barcodeState.canChangePallet && !_isConfirmingPallet
                            ? _confirmNewPallet
                            : null,
                        backgroundColor: Colors.grey.shade400,
                        textColor: Colors.black,
                        textSize: ResponsiveUtils.responsiveFontSize(
                          context,
                          16,
                        ),
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
                        onPressed:
                            (!barcodeState.canChangePallet ||
                                !barcodeState.hasPendingItems)
                            ? null
                            : () {
                                context.read<BarcodeBloc>().add(
                                  BarcodePostCurrentOrderRequested(),
                                );
                              },
                        backgroundColor: Colors.grey.shade400,
                        textColor: Colors.black,
                        textSize: ResponsiveUtils.responsiveFontSize(
                          context,
                          16,
                        ),
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
                                  final items =
                                      await instance<BarcodeRepository>()
                                          .getScannedItems();
                                  await instance<CsvExportService>()
                                      .exportToXlsx(items);
                                } finally {
                                  if (mounted) {
                                    setState(() => _isExporting = false);
                                  }
                                }
                              },
                        backgroundColor: Colors.grey.shade400,
                        textColor: Colors.black,
                        textSize: ResponsiveUtils.responsiveFontSize(
                          context,
                          16,
                        ),
                      ),
                    ),
                    SizedBox(width: gap),

                    // ── Clear (reset screen, keep cache) ─────────────────────
                    Expanded(
                      child: DefaultButton(
                        text: AppLocalizations.of(context)!.clear,
                        onPressed: barcodeState.canChangePallet
                            ? () => _showClearConfirmation(context)
                            : null,
                        backgroundColor: Colors.grey.shade400,
                        textColor: Colors.black,
                        textSize: ResponsiveUtils.responsiveFontSize(
                          context,
                          16,
                        ),
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
