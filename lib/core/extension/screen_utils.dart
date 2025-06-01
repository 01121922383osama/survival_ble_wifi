import 'package:flutter/material.dart';

double calculateChildAspectRatio(
  BuildContext context, {
  required double m,
  required double t,
  required double d,
}) {
  if (context.isMobile) {
    return m;
  }
  if (context.isTablet) {
    return t;
  } else {
    return d;
  }
}

int calculateCrossAxisCount(
  BuildContext context, {
  required int m,
  required int t,
  required int d,
}) {
  if (context.isMobile) {
    return m;
  } else if (context.isTablet) {
    return t;
  } else {
    return d;
  }
}

double getDevice({
  required BuildContext context,
  required double m,
  required double t,
  required double d,
}) {
  if (context.isMobile) {
    return m;
  } else if (context.isTablet) {
    return t;
  } else {
    return d;
  }
}

extension ScreenUTILS on BuildContext {
  double get height => MediaQuery.of(this).size.height;
  bool get isDesktop => width >= 1100;
  bool get isMobile => width < 450;
  bool get isTablet => width >= 450 && width < 1100;
  double get width => MediaQuery.of(this).size.width;
}
