import 'package:flutter/material.dart';
import '../../../../core/resources/responsive_utils.dart';

class LoginHeader extends StatelessWidget {
  final bool compact;

  const LoginHeader({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final double logoHeight = compact
        ? ResponsiveUtils.responsiveHeight(
            context,
            0.16,
          ).clamp(96.0, 160.0).toDouble()
        : ResponsiveUtils.responsiveHeight(context, 0.25);
    final double titleFontSize = ResponsiveUtils.responsiveFontSize(
      context,
      compact ? 21 : 25,
    );
    final double titleGap = compact
        ? ResponsiveUtils.responsiveSpacing(context, 6)
        : ResponsiveUtils.responsiveHeight(context, 0.001);

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
          "Inventory Count",
          style: textTheme.headlineSmall?.copyWith(
            fontSize: titleFontSize,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
