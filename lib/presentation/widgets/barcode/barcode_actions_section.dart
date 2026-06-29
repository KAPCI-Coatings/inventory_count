import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_count_flutter_app/core/widgets/default_button.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/auth/auth_bloc.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/auth/auth_state.dart';

import '../../../../../core/resources/responsive_utils.dart';
import '../../../../../core/routes_manger/routes.dart';

class BarcodeActionsSection extends StatelessWidget {
  const BarcodeActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final double gap = ResponsiveUtils.responsiveSpacing(context, 8);
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final bool isUser = authState.selectedRole.toLowerCase() == 'user';

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
                    onPressed: () => Navigator.of(context).pushNamed(Routes.settings),
                    backgroundColor: Colors.grey.shade400,
                    textColor: Colors.black,
                    textSize: ResponsiveUtils.responsiveFontSize(context, 16),
                  ),
                ),
                SizedBox(width: gap),
                Expanded(
                  child: DefaultButton(
                    text: 'Search',
                    onPressed: () => Navigator.of(context).pushNamed(Routes.search),
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
                    onPressed: () {},
                    backgroundColor: Colors.grey.shade400,
                    textColor: Colors.black,
                    textSize: ResponsiveUtils.responsiveFontSize(context, 16),
                  ),
                ),
                SizedBox(width: gap),
                Expanded(
                  child: DefaultButton(
                    text: 'Export',
                    onPressed: () {},
                    backgroundColor: Colors.grey.shade400,
                    textColor: Colors.black,
                    textSize: ResponsiveUtils.responsiveFontSize(context, 16),
                  ),
                ),
                SizedBox(width: gap),
                Expanded(
                  child: DefaultButton(
                    text: 'Clear',
                    onPressed: () {},
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
  }
}
