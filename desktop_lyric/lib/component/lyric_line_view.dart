import 'dart:async';

import 'package:desktop_lyric/component/lyric_line_display_area.dart';
import 'package:desktop_lyric/player_states.dart';
import 'package:flutter/material.dart';

class LyricLineView extends StatefulWidget {
  const LyricLineView({super.key});

  @override
  State<LyricLineView> createState() => _LyricLineViewState();
}

class _LyricLineViewState extends State<LyricLineView> {
  /// 停留 300ms 后开始滚动，提前 300ms 滚动到底
  final waitFor = const Duration(milliseconds: 300);
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    PlayerStates.instance.lyricLine.addListener(() {
      final line = PlayerStates.instance.lyricLine.value;

      /// 减去启动延时和滚动结束停留时间
      final Duration lastTime = line.length - waitFor - waitFor;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!scrollController.hasClients) return;

        scrollController.jumpTo(0);
        if (scrollController.position.maxScrollExtent > 0) {
          if (lastTime.isNegative) return;

          Future.delayed(waitFor, () {
            if (!scrollController.hasClients) return;

            scrollController.animateTo(
              scrollController.position.maxScrollExtent,
              duration: lastTime,
              curve: Curves.linear,
            );
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        child: const Center(child: LyricLineDisplayArea()),
      ),
    );
  }
}
