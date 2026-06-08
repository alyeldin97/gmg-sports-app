import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppPadding {
  AppPadding._();

  static const EdgeInsets screenH  = EdgeInsets.symmetric(horizontal: 16);
  static const EdgeInsets screenHV = EdgeInsets.symmetric(horizontal: 16, vertical: 20);
  static EdgeInsets get cardPadding => EdgeInsets.all(14.r);

  static double get h4  => 4.h;
  static double get h8  => 8.h;
  static double get h12 => 12.h;
  static double get h16 => 16.h;
  static double get h20 => 20.h;
  static double get h24 => 24.h;
  static double get h32 => 32.h;
}
