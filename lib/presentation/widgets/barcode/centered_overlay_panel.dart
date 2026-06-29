import 'package:flutter/material.dart';
import 'package:inventory_count_flutter_app/core/resources/responsive_utils.dart';
import 'package:inventory_count_flutter_app/l10n/app_localizations.dart';

class CenteredOverlayPanel extends StatelessWidget {
  final String message;
  final Color color;
  final VoidCallback? onAcknowledge;
  final VoidCallback? onConfirm;
  final VoidCallback? onReject;
  final bool isWarning;

  const CenteredOverlayPanel({
    super.key,
    required this.message,
    required this.color,
    this.onAcknowledge,
    this.onConfirm,
    this.onReject,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final double panelWidth = ResponsiveUtils.responsiveWidth(
      context,
      0.84,
    ).clamp(260.0, 380.0);

    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: isWarning ? () {} : onAcknowledge,
        child: Center(
          child: Container(
            width: panelWidth,
            margin: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.responsiveSpacing(context, 20),
            ),
            padding: EdgeInsets.all(
              ResponsiveUtils.responsiveSpacing(context, 16),
            ),
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: color, width: 2),
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.responsiveRadius(context, 10),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: ResponsiveUtils.responsiveSpacing(context, 16),
                ),
                if (isWarning)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: color,
                        ),
                        onPressed: onConfirm,
                        child: Text(AppLocalizations.of(context)!.yes),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.red,
                        ),
                        onPressed: onReject,
                        child: Text(AppLocalizations.of(context)!.no),
                      ),
                    ],
                  )
                else if (onAcknowledge != null)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: color,
                    ),
                    onPressed: onAcknowledge,
                    child: Text(AppLocalizations.of(context)!.ok),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
