import 'package:flutter/material.dart';

class MotionTokens {
  static const Duration quick = Duration(milliseconds: 500);
  static const Duration medium = Duration(milliseconds: 900);
  static const Duration slow = Duration(milliseconds: 1400);

  static const Curve entrance = Curves.easeOutCubic;
  static const Curve emphasis = Curves.easeInOutCubic;
}

