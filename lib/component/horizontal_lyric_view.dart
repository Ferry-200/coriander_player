import 'dart:async';
import 'dart:math';

import 'package:coriander_player/lyric/lrc.dart';
import 'package:coriander_player/play_service.dart';
import 'package:coriander_player/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HorizontalLyricView extends StatelessWidget {
  const HorizontalLyricView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.palette.secondaryContainer,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: const _LyricHorizontalScrollArea(),
    );
  }
}

class _LyricHorizontalScrollArea extends StatefulWidget {
  const _LyricHorizontalScrollArea();

  @override
  State<_LyricHorizontalScrollArea> createState() =>
      _LyricHorizontalScrollAreaState();
}

class _LyricHorizontalScrollAreaState
    extends State<_LyricHorizontalScrollArea> {
  /// 停留300ms后启动，提前300ms滚动到底
  final waitFor = const Duration(milliseconds: 300);
  final scrollController = ScrollController();
  final playService = PlayService.instance;
  late StreamSubscription lyricLineStreamSubscription;

  Lrc? lyric;
  var currentLyricLine = "Enjoy Music";

  @override
  void initState() {
    super.initState();

    lyric = playService.nowPlayingLyric;

    playService.addListener(_updateLyric);

    lyricLineStreamSubscription = playService.lyricLineStream.listen((line) {
      if (lyric == null) return;

      setState(() {
        currentLyricLine = lyric!.lines[line].content;
      });

      /// 减去启动延时和滚动结束停留时间
      final lastTime =
          lyric!.lines[min(line + 1, lyric!.lines.length - 1)].time -
              lyric!.lines[line].time -
              waitFor -
              waitFor;

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

  /// 重新获取歌词
  void _updateLyric() {
    lyric = playService.nowPlayingLyric;
    setState(() {
      if (lyric == null) {
        currentLyricLine = "Enjoy Music";
      } else {
        if (lyric!.lines.isNotEmpty) {
          currentLyricLine = lyric!.lines.first.content;
        } else {
          currentLyricLine = "Enjoy Music";
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SingleChildScrollView(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            currentLyricLine,
            style: TextStyle(
              color: theme.palette.onSecondaryContainer,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    lyricLineStreamSubscription.cancel();
    playService.removeListener(_updateLyric);
    scrollController.dispose();
  }
}
