import 'package:flutter/material.dart';
import '../../../../../../../core/resources/responsive_utils.dart';
import '../../../../../../../l10n/app_localizations.dart';

class LoginHeader extends StatelessWidget {
  final bool compact;

  const LoginHeader({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final TextTheme textTheme = Theme.of(context).textTheme;
    final double logoHeight = compact
        ? ResponsiveUtils.responsiveHeight(
            context,
            0.16,
          ).clamp(96.0, 160.0).toDouble()
        : ResponsiveUtils.responsiveHeight(context, 0.25);
    final double titleFontSize = ResponsiveUtils.responsiveFontSize(
      context,
      compact ? 24 : 32,
    );
    final double titleGap = compact
        ? ResponsiveUtils.responsiveSpacing(context, 12)
        : ResponsiveUtils.responsiveHeight(context, 0.02);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Image.asset(
          'assets/images/Icon_logo.png',
          height: logoHeight,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.inventory_2,
              size: logoHeight,
              color: Theme.of(context).primaryColor,
            );
          },
        ),
        SizedBox(height: titleGap),
        Text(
          l10n?.inventoryCount ?? "Inventory Count",
          style: textTheme.headlineMedium?.copyWith(
            fontSize: titleFontSize,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
