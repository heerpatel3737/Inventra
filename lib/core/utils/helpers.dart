import 'package:flutter/material.dart';

class Helpers {
  static bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 1100;
  static bool isTablet(BuildContext context) => MediaQuery.of(context).size.width >= 700 && MediaQuery.of(context).size.width < 1100;

  static int responsiveGridCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1400) return 4;
    if (width >= 1000) return 3;
    if (width >= 700) return 2;
    return 1;
  }
}


