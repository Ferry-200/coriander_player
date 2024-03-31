import 'dart:async';
import 'dart:math';

import 'package:coriander_player/lyric/lyric.dart';
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

  Lyric? lyric;
  var currContent = "Enjoy Music";

  @override
  void initState() {
    super.initState();

    lyric = playService.currentLyric.value;

    playService.currentLyric.addListener(_updateLyric);

    lyricLineStreamSubscription = playService.lyricLineStream.listen((line) {
      if (lyric == null || lyric!.lines.isEmpty) return;
      final currLine = lyric!.lines[line];

      setState(() {
        if (currLine is UnsyncLyricLine) {
          currContent = currLine.content;
        } else if (currLine is SyncLyricLine) {
          currContent = currLine.content;
        }
      });

      /// 减去启动延时和滚动结束停留时间
      late final Duration lastTime;
      if (currLine is UnsyncLyricLine) {
        lastTime = lyric!.lines[min(line + 1, lyric!.lines.length - 1)].start -
            currLine.start -
            waitFor -
            waitFor;
      } else if (currLine is SyncLyricLine) {
        lastTime = currLine.length - waitFor - waitFor;
      }

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
    lyric = playService.currentLyric.value;
    setState(() {
      if (lyric == null) {
        currContent = "Enjoy Music";
      } else {
        if (lyric!.lines.isNotEmpty) {
          final first = lyric!.lines.first;
          if (first is UnsyncLyricLine) {
            currContent = first.content;
          } else if (first is SyncLyricLine) {
            currContent = first.content;
          }
        } else {
          currContent = "Enjoy Music";
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
            currContent,
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
    playService.currentLyric.removeListener(_updateLyric);
    scrollController.dispose();
  }
}
