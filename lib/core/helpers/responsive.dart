import 'package:flutter/material.dart';

class Responsive {
  static const double _mobileBreak  = 600;
  static const double _tabletBreak  = 900;
  static const double _desktopBreak = 1200;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < _mobileBreak;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= _desktopBreak;

  static int gridCrossAxisCount(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= _desktopBreak) return 4;
    if (w >= _tabletBreak)  return 3;
    return 2;
  }

  static double maxContentWidth(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= _desktopBreak) return 1100;
    return double.infinity;
  }

  static double sp(BuildContext context, double base) {
    final w = MediaQuery.of(context).size.width;
    if (w >= _mobileBreak) return base;
    return base * (w / 390.0).clamp(0.85, 1.0);
  }
}
