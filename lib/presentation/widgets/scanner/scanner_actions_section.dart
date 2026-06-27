import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_count_flutter_app/core/widgets/default_button.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/auth/auth_bloc.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/auth/auth_state.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/scanner/scanner_bloc.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/scanner/scanner_event.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/scanner/scanner_state.dart';

import '../../../../../core/resources/responsive_utils.dart';
import '../../../../../core/routes_manger/routes.dart';

class ScannerActionsSection extends StatelessWidget {
  const ScannerActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final double gap = ResponsiveUtils.responsiveSpacing(context, 8);
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final bool isUser = authState.selectedRole.toLowerCase() == 'user';

        return BlocBuilder<ScannerBloc, ScannerState>(
          builder: (context, state) {
            final bool isBusy =
                state.status == ScannerStatus.loading ||
                state.status == ScannerStatus.posting;

            if (isUser) {
              return Center(
                child: DefaultButton(
                  text: 'Exit',
                  onPressed: () =>
                      Navigator.of(context).pushReplacementNamed(Routes.login),
                  backgroundColor: Colors.grey.shade400,
                  textColor: Colors.black,
                  textSize: ResponsiveUtils.responsiveFontSize(context, 16),
                  width: ResponsiveUtils.responsiveWidth(context, 0.4),
                  height: ResponsiveUtils.responsiveHeight(context, 0.07).clamp(48, 64),
                ),
              );
            }

            return Column(
              children: [
                Row(
                  children: <Widget>[
                    Expanded(
                      child: DefaultButton(
                        text: 'Settings',
                        onPressed: isBusy
                            ? null
                            : () => Navigator.of(context).pushNamed(Routes.settings),
                        backgroundColor: Colors.grey.shade400,
                        textColor: Colors.black,
                        textSize: ResponsiveUtils.responsiveFontSize(context, 16),
                      ),
                    ),
                    SizedBox(width: gap),
                    Expanded(
                      child: DefaultButton(
                        text: 'Search',
                        onPressed: isBusy
                            ? null
                            : () => Navigator.of(context).pushNamed(Routes.search),
                        backgroundColor: Colors.grey.shade400,
                        textColor: Colors.black,
                        textSize: ResponsiveUtils.responsiveFontSize(context, 16),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: gap),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: DefaultButton(
                        text: 'Send',
                        onPressed: isBusy
                            ? null
                            : () => context.read<ScannerBloc>().add(
                                ScannerPostCurrentOrderRequested(),
                              ),
                        backgroundColor: Colors.grey.shade400,
                        textColor: Colors.black,
                        textSize: ResponsiveUtils.responsiveFontSize(context, 16),
                      ),
                    ),
                    SizedBox(width: gap),
                    Expanded(
                      child: DefaultButton(
                        text: 'Export',
                        onPressed: isBusy
                            ? null
                            : () {
                                /* TODO: handle export */
                              },
                        backgroundColor: Colors.grey.shade400,
                        textColor: Colors.black,
                        textSize: ResponsiveUtils.responsiveFontSize(context, 16),
                      ),
                    ),
                    SizedBox(width: gap),
                    Expanded(
                      child: DefaultButton(
                        text: 'Clear',
                        onPressed: isBusy
                            ? null
                            : () => context.read<ScannerBloc>().add(
                                ScannerNewOrderRequested(),
                              ),
                        backgroundColor: Colors.grey.shade400,
                        textColor: Colors.black,
                        textSize: ResponsiveUtils.responsiveFontSize(context, 16),
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
