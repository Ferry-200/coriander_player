import 'package:desktop_lyric/component/foreground.dart';
import 'package:desktop_lyric/message.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

class DesktopLyricBody extends StatefulWidget {
  const DesktopLyricBody({super.key});

  @override
  State<DesktopLyricBody> createState() => _DesktopLyricBodyState();
}

class _DesktopLyricBodyState extends State<DesktopLyricBody> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeChangedMessage>();

    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 300),
      tween: isHovering
          ? ColorTween(
              begin: const Color.fromARGB(0, 255, 255, 255),
              end: theme.surfaceContainer,
            )
          : ColorTween(
              begin: theme.surfaceContainer,
              end: const Color.fromARGB(0, 255, 255, 255),
            ),
      builder: (context, value, child) => ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Scaffold(backgroundColor: value, body: child),
      ),
      child: MouseRegion(
        onEnter: (_) {
          setState(() {
            isHovering = true;
          });
        },
        onExit: (_) {
          setState(() {
            isHovering = false;
          });
        },
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onPanStart: (details) {
            windowManager.startDragging();
          },
          child: Center(child: DesktopLyricForeground(isHovering: isHovering)),
        ),
      ),
    );
  }
}
