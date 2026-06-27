import 'package:flutter/material.dart';
import 'package:inventory_count_flutter_app/core/widgets/default_button.dart';
import 'package:inventory_count_flutter_app/l10n/app_localizations.dart';
import 'package:inventory_count_flutter_app/core/resources/responsive_utils.dart';
import 'package:inventory_count_flutter_app/core/routes_manger/routes.dart';
import 'package:inventory_count_flutter_app/core/widgets/screen_title.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/auth/auth_bloc.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/auth/auth_state.dart';

class AssetsScreen extends StatelessWidget {
  const AssetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(ResponsiveUtils.responsiveSpacing(context, 24.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Title "Assets"
              ScreenTitle(title: AppLocalizations.of(context)!.assetsTitle),
              SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 60)),

              // 2. Asset No : 123
              Text(
                '${AppLocalizations.of(context)!.assetNo} : 123',
                style: TextStyle(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, 24),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              
              SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 16)),
              const Divider(color: Colors.black, thickness: 1.5),
              SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 16)),

              // 3. Asset Count : 123
              Text(
                '${AppLocalizations.of(context)!.assetCount} : 123',
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
                  final bool isUser = authState.selectedRole.toLowerCase() == 'user';
                  final double gap = ResponsiveUtils.responsiveSpacing(context, 8);

                  if (isUser) {
                    return Center(
                      child: DefaultButton(
                        text: AppLocalizations.of(context)!.exit,
                        width: ResponsiveUtils.responsiveWidth(context, 0.4),
                        height: ResponsiveUtils.responsiveHeight(context, 0.07).clamp(48, 64),
                        textSize: ResponsiveUtils.responsiveFontSize(context, 16),
                        backgroundColor: Colors.grey.shade400,
                        textColor: Colors.black,
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed(Routes.login);
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
                              height: ResponsiveUtils.responsiveHeight(context, 0.07).clamp(48, 64),
                              textSize: ResponsiveUtils.responsiveFontSize(context, 16),
                              backgroundColor: Colors.grey.shade400,
                              textColor: Colors.black,
                              onPressed: () {
                                Navigator.of(context).pushNamed(Routes.settings);
                              },
                            ),
                          ),
                          SizedBox(width: gap),
                          Expanded(
                            child: DefaultButton(
                              text: 'Export',
                              height: ResponsiveUtils.responsiveHeight(context, 0.07).clamp(48, 64),
                              textSize: ResponsiveUtils.responsiveFontSize(context, 16),
                              backgroundColor: Colors.grey.shade400,
                              textColor: Colors.black,
                              onPressed: () {
                                /* TODO: handle export */
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
                              text: 'Clear',
                              height: ResponsiveUtils.responsiveHeight(context, 0.07).clamp(48, 64),
                              textSize: ResponsiveUtils.responsiveFontSize(context, 16),
                              backgroundColor: Colors.grey.shade400,
                              textColor: Colors.black,
                              onPressed: () {
                                /* TODO: handle clear */
                              },
                            ),
                          ),
                          SizedBox(width: gap),
                          Expanded(
                            child: DefaultButton(
                              text: AppLocalizations.of(context)!.exit,
                              height: ResponsiveUtils.responsiveHeight(context, 0.07).clamp(48, 64),
                              textSize: ResponsiveUtils.responsiveFontSize(context, 16),
                              backgroundColor: Colors.grey.shade400,
                              textColor: Colors.black,
                              onPressed: () {
                                Navigator.of(context).pushReplacementNamed(Routes.login);
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
    );
  }
}
