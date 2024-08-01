import 'package:desktop_lyric/component/action_row.dart';
import 'package:desktop_lyric/component/lyric_line_view.dart';
import 'package:desktop_lyric/component/now_playing_info.dart';
import 'package:flutter/material.dart';

class DesktopLyricForeground extends StatelessWidget {
  final bool isHovering;
  const DesktopLyricForeground({super.key, required this.isHovering});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: isHovering ? const ActionRow() : const NowPlayingInfo(),
          ),
        ),
        const Expanded(child: LyricLineView()),
      ],
    );
  }
}
