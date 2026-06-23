import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/scanner/scanner_bloc.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/scanner/scanner_event.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/scanner/scanner_state.dart';
import 'package:inventory_count_flutter_app/presentation/widgets/scanner/scanner_actions_section.dart';
import 'package:inventory_count_flutter_app/presentation/widgets/scanner/scanner_status_section.dart';

import '../../core/resources/responsive_utils.dart';

import '../widgets/scanner/scanner_app_bar.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScannerBloc, ScannerState>(
      listenWhen: (previous, current) => previous.message != current.message,
      listener: (context, state) {
        if (state.message == null || state.message!.isEmpty) {
          return;
        }

        if (state.centeredErrorMessage != null &&
            state.centeredErrorMessage!.isNotEmpty) {
          return;
        }

        if (state.centeredSuccessMessage != null &&
            state.centeredSuccessMessage!.isNotEmpty) {
          return;
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.message!)));
        context.read<ScannerBloc>().add(ScannerClearMessageRequested());
      },
      child: Scaffold(
        appBar: const ScannerAppBar(),
        body: SafeArea(
          child: BlocBuilder<ScannerBloc, ScannerState>(
            buildWhen: (previous, current) =>
                previous.centeredErrorMessage != current.centeredErrorMessage ||
                previous.centeredSuccessMessage !=
                    current.centeredSuccessMessage ||
                previous.centeredWarningMessage !=
                    current.centeredWarningMessage,
            builder: (context, state) {
              final bool hasCenteredError = state.centeredErrorMessage != null &&
                  state.centeredErrorMessage!.isNotEmpty;
              final bool hasCenteredSuccess =
                  state.centeredSuccessMessage != null &&
                  state.centeredSuccessMessage!.isNotEmpty;

              final bool hasCenteredWarning =
                  state.centeredWarningMessage != null &&
                  state.centeredWarningMessage!.isNotEmpty;

              final bool showCenteredOverlay =
                  hasCenteredError || hasCenteredSuccess;
              final bool showAcknowledgeButton = hasCenteredError;
              final String overlayMessage = hasCenteredError
                  ? state.centeredErrorMessage!
                  : (hasCenteredSuccess ? state.centeredSuccessMessage! : '');
              final Color overlayColor =
                  hasCenteredError ? Colors.red : Colors.green;

              final double pagePadding = ResponsiveUtils.responsiveSpacing(
                context,
                16,
              );
              final double panelWidth = ResponsiveUtils.responsiveWidth(
                context,
                0.84,
              ).clamp(260, 380).toDouble();

              return Stack(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(pagePadding),
                    child: Column(
                      children: <Widget>[
                        const ScannerStatusSection(),
                        const Spacer(),
                        const ScannerActionsSection(),
                      ],
                    ),
                  ),
                  if (showCenteredOverlay)
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => context
                            .read<ScannerBloc>()
                            .add(ScannerDismissCenteredMessageRequested()),
                        child: Center(
                          child: Container(
                            width: panelWidth,
                            margin: EdgeInsets.symmetric(
                              horizontal: ResponsiveUtils.responsiveSpacing(
                                context,
                                20,
                              ),
                            ),
                            padding: EdgeInsets.all(
                              ResponsiveUtils.responsiveSpacing(context, 16),
                            ),
                            decoration: BoxDecoration(
                              color: overlayColor,
                              border: Border.all(color: overlayColor, width: 2),
                              borderRadius: BorderRadius.circular(
                                ResponsiveUtils.responsiveRadius(context, 10),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  overlayMessage,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ResponsiveUtils.responsiveFontSize(
                                      context,
                                      16,
                                    ),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(
                                  height: ResponsiveUtils.responsiveSpacing(
                                    context,
                                    16,
                                  ),
                                ),
                                if (showAcknowledgeButton)
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: overlayColor,
                                    ),
                                    onPressed: () => context
                                        .read<ScannerBloc>()
                                        .add(ScannerDismissCenteredMessageRequested()),
                                    child: const Text('موافق'),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  // ── Warning overlay (duplicate pallet confirmation) ──
                  if (hasCenteredWarning)
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {}, // block taps on background
                        child: Center(
                          child: Container(
                            width: panelWidth,
                            margin: EdgeInsets.symmetric(
                              horizontal: ResponsiveUtils.responsiveSpacing(
                                context,
                                20,
                              ),
                            ),
                            padding: EdgeInsets.all(
                              ResponsiveUtils.responsiveSpacing(context, 16),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              border: Border.all(color: Colors.orange, width: 2),
                              borderRadius: BorderRadius.circular(
                                ResponsiveUtils.responsiveRadius(context, 10),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  state.centeredWarningMessage!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ResponsiveUtils.responsiveFontSize(
                                      context,
                                      16,
                                    ),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(
                                  height: ResponsiveUtils.responsiveSpacing(
                                    context,
                                    16,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.orange,
                                      ),
                                      onPressed: () => context
                                          .read<ScannerBloc>()
                                          .add(ScannerDuplicatePalletConfirmed()),
                                      child: const Text('نعم'),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.red,
                                      ),
                                      onPressed: () => context
                                          .read<ScannerBloc>()
                                          .add(ScannerDuplicatePalletRejected()),
                                      child: const Text('لا'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
