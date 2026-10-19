import 'dart:math' as math;

import 'package:flutter/widgets.dart';

class ResponsiveUtils {
  ResponsiveUtils._();

  static const double _defaultBaseWidth = 390;
  static const double _defaultBaseHeight = 844;

  static Size screenSize(BuildContext context) {
    return MediaQuery.sizeOf(context);
  }

  static double screenWidth(BuildContext context) {
    return screenSize(context).width;
  }

  static double screenHeight(BuildContext context) {
    return screenSize(context).height;
  }

  static double getScaleFactor(
    BuildContext context, {
    double baseWidth = _defaultBaseWidth,
    double baseHeight = _defaultBaseHeight,
    double minScale = 0.85,
    double maxScale = 1.25,
  }) {
    final size = screenSize(context);
    final widthScale = size.width / baseWidth;
    final heightScale = size.height / baseHeight;
    final rawScale = math.min(widthScale, heightScale);
    return rawScale.clamp(minScale, maxScale).toDouble();
  }

  static double responsiveSize(
    BuildContext context,
    double baseSize, {
    double minScale = 0.85,
    double maxScale = 1.25,
  }) {
    final scale = getScaleFactor(
      context,
      minScale: minScale,
      maxScale: maxScale,
    );
    return baseSize * scale;
  }

  static double responsiveFontSize(
    BuildContext context,
    double baseSize, {
    double minScale = 0.85,
    double maxScale = 1.2,
  }) {
    return responsiveSize(
      context,
      baseSize,
      minScale: minScale,
      maxScale: maxScale,
    );
  }

  static double responsiveSpacing(
    BuildContext context,
    double baseSpacing, {
    double minScale = 0.85,
    double maxScale = 1.25,
  }) {
    return responsiveSize(
      context,
      baseSpacing,
      minScale: minScale,
      maxScale: maxScale,
    );
  }

  static double responsiveRadius(
    BuildContext context,
    double baseRadius, {
    double minScale = 0.85,
    double maxScale = 1.2,
  }) {
    return responsiveSize(
      context,
      baseRadius,
      minScale: minScale,
      maxScale: maxScale,
    );
  }

  static double responsiveHeight(BuildContext context, double percentage) {
    return screenHeight(context) * percentage;
  }

  static double responsiveWidth(BuildContext context, double percentage) {
    return screenWidth(context) * percentage;
  }

  static bool isTablet(BuildContext context) {
    return screenSize(context).shortestSide >= 600;
  }

  static bool isSmallPhone(BuildContext context) {
    return screenWidth(context) < 360;
  }

  static int adaptiveGridCount(
    BuildContext context, {
    int phone = 2,
    int tablet = 3,
    int desktop = 4,
  }) {
    final width = screenWidth(context);
    if (width >= 1024) {
      return desktop;
    }
    if (width >= 600) {
      return tablet;
    }
    return phone;
  }
}
