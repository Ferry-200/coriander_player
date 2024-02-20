import 'package:flutter/material.dart';

enum ScreenType {
  /// width <= 640
  small,

  /// 640 < width < 1100
  medium,

  /// width >= 1100
  large,
}

class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, ScreenType screenType) builder;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    if (screenSize.width <= 640) {
      return builder(context, ScreenType.small);
    } else if (screenSize.width > 640 && screenSize.width < 1100) {
      return builder(context, ScreenType.medium);
    } else {
      return builder(context, ScreenType.large);
    }
  }
}
