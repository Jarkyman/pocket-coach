import 'package:flutter/material.dart';

abstract class AppMotion {
  // Durations
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration pageTransition = Duration(milliseconds: 400);

  // Curves
  static const Curve defaultCurve = Curves.fastOutSlowIn;
  static const Curve emphasizeCurve = Curves.easeInOutCubic;
  static const Curve deceleration = Curves.decelerate;
}
