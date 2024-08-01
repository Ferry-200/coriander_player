import 'package:desktop_lyric/component/action_row.dart';
import 'package:desktop_lyric/component/lyric_line_view.dart';
import 'package:desktop_lyric/component/now_playing_info.dart';
import 'package:flutter/material.dart';

class DesktopLyricForeground extends StatelessWidget {
  final bool isHovering;
  const DesktopLyricForeground({super.key, required this.isHovering});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: isHovering
                ? const RepaintBoundary(child: ActionRow())
                : const RepaintBoundary(child: NowPlayingInfo()),
          ),
          const SizedBox(height: 8),
          const LyricLineView(),
        ],
      ),
    );
  }
}
