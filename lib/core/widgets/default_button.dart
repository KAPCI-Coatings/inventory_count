import 'package:flutter/material.dart';
import 'package:inventory_count_flutter_app/core/resources/responsive_utils.dart';
import 'package:inventory_count_flutter_app/core/utils/colors.dart';

class DefaultButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double? height;
  final double? textSize;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final FocusNode? focusNode;
  final bool canRequestFocus;

  const DefaultButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
    this.textSize,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.focusNode,
    this.canRequestFocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final double radius = ResponsiveUtils.responsiveRadius(context, 15);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Focus(
        canRequestFocus: canRequestFocus,
        skipTraversal: !canRequestFocus,
        child: ElevatedButton(
          focusNode: focusNode,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppColors.button,
            foregroundColor: textColor ?? AppColors.text,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
              side: BorderSide(color: borderColor ?? Colors.black, width: 2),
            ),
          ),
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.black,
                  ),
                )
              : FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    text,
                    style: textTheme.titleMedium?.copyWith(
                      fontSize: textSize ?? ResponsiveUtils.responsiveFontSize(context, 16),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
