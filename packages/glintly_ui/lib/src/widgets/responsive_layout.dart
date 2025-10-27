import 'package:flutter/material.dart';

class Breakpoints {
  static const double phone = 600;
  static const double tablet = 1024;
}

typedef ResponsiveBuilder = Widget Function(
  BuildContext context,
  BoxConstraints constraints,
);

class ResponsiveLayout extends StatelessWidget {
  final Widget phone;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.phone,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width >= Breakpoints.tablet) {
          return desktop ?? tablet ?? phone;
        }
        if (width >= Breakpoints.phone) {
          return tablet ?? phone;
        }
        return phone;
      },
    );
  }
}

