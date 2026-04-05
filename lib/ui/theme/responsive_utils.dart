import 'package:flutter/material.dart';

class ResponsiveUtils {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1200;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
      MediaQuery.of(context).size.width < tabletBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;

  static double getResponsiveWidth(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width >= tabletBreakpoint) {
      return 1000; // Max width for desktop
    } else if (width >= mobileBreakpoint) {
      return 600; // Max width for tablet
    } else {
      return width; // Full width for mobile
    }
  }

  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 40, vertical: 40);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 30, vertical: 30);
    } else {
      return const EdgeInsets.symmetric(horizontal: 20, vertical: 20);
    }
  }
}
