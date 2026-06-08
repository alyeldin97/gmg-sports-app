import 'package:flutter/material.dart';

/// GMG Sports brand palette — bold amber/gold on near-black, white surfaces.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary      = Color(0xFFFFC107); // GMG amber/gold
  static const Color primaryDark  = Color(0xFFF5A800);
  static const Color primaryLight = Color(0xFFFFE082);
  static const Color primaryMist  = Color(0xFFFFF8E1);

  // Ink (brand black)
  static const Color ink          = Color(0xFF141414);
  static const Color inkSoft      = Color(0xFF242424);

  static const Color scaffoldBg   = Color(0xFFF6F6F7);
  static const Color white        = Color(0xFFFFFFFF);

  static const Color textDark      = Color(0xFF141414);
  static const Color textCharcoal  = Color(0xFF2D2D2D);
  static const Color textMid       = Color(0xFF6A6A6A);
  static const Color textLight     = Color(0xFF9A9A9A);

  static const Color accentGreen   = Color(0xFF2E9E5B); // success / delivered
  static const Color accentOrange  = Color(0xFFE67E22);

  static const Color border        = Color(0xFFE6E6E8);
  static const Color error         = Color(0xFFE25555);
}
