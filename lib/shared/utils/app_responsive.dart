import 'dart:math' as math;

import 'package:flutter/material.dart';

class AppResponsive {
  const AppResponsive._();

  static double scale(BuildContext context,
      {double min = 0.72, double max = 1.15}) {
    final size = MediaQuery.sizeOf(context);
    final widthScale = size.width / 393;
    final heightScale = size.height / 852;

    return math.min(widthScale, heightScale).clamp(min, max).toDouble();
  }

  static double pagePadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return (width * 0.04).clamp(10.0, 20.0).toDouble();
  }

  static double authPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return (width * 0.055).clamp(14.0, 30.0).toDouble();
  }

  static bool isNarrow(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 360;
}
