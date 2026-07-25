import 'dart:async';
import 'package:flutter/material.dart';
import 'package:inventory_count_flutter_app/core/widgets/default_button.dart';
import 'package:inventory_count_flutter_app/l10n/app_localizations.dart';
import 'package:inventory_count_flutter_app/core/resources/responsive_utils.dart';
import 'package:inventory_count_flutter_app/core/routes_manger/routes.dart';
import 'package:inventory_count_flutter_app/core/widgets/screen_title.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/auth/auth_bloc.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/auth/auth_event.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/auth/auth_state.dart';
import 'package:inventory_count_flutter_app/core/di/di.dart';
import 'package:inventory_count_flutter_app/core/services/csv_export_service.dart';
import 'package:inventory_count_flutter_app/data/datasources/asset_local_datasource.dart';
import 'package:inventory_count_flutter_app/domain/entities/asset_scan.dart';
import 'package:inventory_count_flutter_app/core/services/scanner_service.dart';

class AssetsScreen extends StatefulWidget {
  const AssetsScreen({super.key});

  @override
  State<AssetsScreen> createState() => _AssetsScreenState();
}

class _AssetsScreenState extends State<AssetsScreen> {
  final AssetLocalDataSource _assetDataSource = instance<AssetLocalDataSource>();
  final ScannerService _scannerService = instance<ScannerService>();
  StreamSubscription<ScanResult>? _scanSubscription;

  int _assetCount = 0;
  String _lastAssetNo = '-';
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

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _setupScanner();
  }

  Future<void> _loadInitialData() async {
    final count = await _assetDataSource.getAssetCount();
    final scans = await _assetDataSource.getAssetScans();
    setState(() {
      _assetCount = count;
      if (scans.isNotEmpty) {
        _lastAssetNo = scans.first.barcode;
      }
    });
  }

  void _setupScanner() {
    // Cancel any existing subscription before creating a new one.
    // This makes _setupScanner safe to call multiple times (e.g. after export).
    _scanSubscription?.cancel();
    _scanSubscription = null;

    _scannerService.enableScanner();
    _scanSubscription = _scannerService.onScan.listen((result) async {
      try {
        final barcode = result.data.trim();
        if (barcode.isEmpty) return;

        final scan = AssetScan(barcode: barcode, scannedAt: DateTime.now());
        await _assetDataSource.saveAssetScan(scan);

        if (!mounted) return;
        setState(() {
          _lastAssetNo = barcode;
          _assetCount += 1;
        });

        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text('${AppLocalizations.of(context)?.assetNo ?? "Asset No"}: $barcode'),
              duration: const Duration(seconds: 2),
            ),
          );
      } catch (e) {
        debugPrint('[AssetsScreen] Error processing scan: $e');
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Error: $e'), duration: const Duration(seconds: 2)),
           );
        }
      }
    });
    debugPrint('[AssetsScreen] Scanner setup complete, subscription active');
  }

  Future<void> _confirmAndClear(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(l10n?.clear ?? 'Clear',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(l10n?.confirm_clear_screen ??
            'Reset the screen? Scanned data will remain saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n?.no ?? 'No'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black87),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n?.yes ?? 'Yes',
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() {
        _assetCount = 0;
        _lastAssetNo = '-';
      });
    }
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    // Do NOT call disableScanner() here — the ScannerService is a shared
    // singleton. Disabling the hardware from one screen would break all
    // other screens that also depend on the same scanner.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FocusScope(
        canRequestFocus: false,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(ResponsiveUtils.responsiveSpacing(context, 24.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Title "Assets"
                ScreenTitle(title: AppLocalizations.of(context)!.assetsTitle),
                SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 60)),

                // 2. Asset No
                Text(
                  '${AppLocalizations.of(context)!.assetNo} : $_lastAssetNo',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.responsiveFontSize(context, 24),
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 16)),
                const Divider(color: Colors.black, thickness: 1.5),
                SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 16)),

                // 3. Asset Count
                Text(
                  '${AppLocalizations.of(context)!.assetCount} : $_assetCount',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.responsiveFontSize(context, 24),
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const Spacer(),

                // 4. Action buttons
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    final bool isUser =
                        authState.selectedRole.toLowerCase() == 'user';
                    final double gap =
                        ResponsiveUtils.responsiveSpacing(context, 8);

                    if (isUser) {
                      return Center(
                        child: DefaultButton(
                          text: AppLocalizations.of(context)!.exit,
                          width: ResponsiveUtils.responsiveWidth(context, 0.4),
                          height: ResponsiveUtils.responsiveHeight(context, 0.07)
                              .clamp(48, 64),
                          textSize:
                              ResponsiveUtils.responsiveFontSize(context, 16),
                          backgroundColor: Colors.grey.shade400,
                          textColor: Colors.black,
                          onPressed: () {
                            context
                                .read<AuthBloc>()
                                .add(const AuthLogoutRequested());
                            Navigator.of(context)
                                .pushReplacementNamed(Routes.login);
                          },
                        ),
                      );
                    }

                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: DefaultButton(
                                text: AppLocalizations.of(context)!.settings,
                                height: ResponsiveUtils.responsiveHeight(
                                        context, 0.07)
                                    .clamp(48, 64),
                                textSize:
                                    ResponsiveUtils.responsiveFontSize(context, 16),
                                backgroundColor: Colors.grey.shade400,
                                textColor: Colors.black,
                                onPressed: () => _navigateToRoute(Routes.settings),
                              ),
                            ),
                          SizedBox(width: gap),
                          Expanded(
                            child: DefaultButton(
                              text: AppLocalizations.of(context)!.export,
                              height: ResponsiveUtils.responsiveHeight(
                                      context, 0.07)
                                  .clamp(48, 64),
                              textSize:
                                  ResponsiveUtils.responsiveFontSize(context, 16),
                              backgroundColor: Colors.grey.shade400,
                              textColor: Colors.black,
                              onPressed: () async {
                                final items =
                                    await _assetDataSource.getAssetScans();
                                await instance<CsvExportService>()
                                    .exportAssetScansToCsv(items);
                                
                                await _assetDataSource.clearAssetScans();
                                if (!mounted) return;
                                setState(() {
                                  _assetCount = 0;
                                  _lastAssetNo = '-';
                                });

                                // Re-establish scanner subscription.
                                // The native file-save dialog can disrupt the
                                // broadcast stream subscription, so we create
                                // a fresh one to guarantee scans keep working.
                                _setupScanner();
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: gap),
                      Row(
                        children: [
                          Expanded(
                            child: DefaultButton(
                              text: AppLocalizations.of(context)!.clear,
                              height: ResponsiveUtils.responsiveHeight(
                                      context, 0.07)
                                  .clamp(48, 64),
                              textSize:
                                  ResponsiveUtils.responsiveFontSize(context, 16),
                              backgroundColor: Colors.grey.shade400,
                              textColor: Colors.black,
                              // Clear resets the screen counters ONLY — DB data stays
                              onPressed: () => _confirmAndClear(context),
                            ),
                          ),
                          SizedBox(width: gap),
                          Expanded(
                            child: DefaultButton(
                              text: AppLocalizations.of(context)!.exit,
                              height: ResponsiveUtils.responsiveHeight(
                                      context, 0.07)
                                  .clamp(48, 64),
                              textSize:
                                  ResponsiveUtils.responsiveFontSize(context, 16),
                              backgroundColor: Colors.grey.shade400,
                              textColor: Colors.black,
                              onPressed: () {
                                context
                                    .read<AuthBloc>()
                                    .add(const AuthLogoutRequested());
                                Navigator.of(context)
                                    .pushReplacementNamed(Routes.login);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 24)),
            ],
          ),
        ),
      ),
    ),
  );
}
}
