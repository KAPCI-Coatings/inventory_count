import 'package:flutter/material.dart';
import 'package:inventory_count_flutter_app/core/resources/responsive_utils.dart';

class ScreenTitle extends StatelessWidget {
  final String title;

  const ScreenTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: ResponsiveUtils.responsiveFontSize(context, 42),
        fontWeight: FontWeight.bold,
        color: Colors.black,
        shadows: const <Shadow>[
          Shadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
    );
  }
}
