import 'dart:async';

import 'package:coriander_player/lyric/lrc.dart';
import 'package:coriander_player/lyric/lyric.dart';
import 'package:coriander_player/play_service/play_service.dart';
import 'package:flutter/material.dart';

class HorizontalLyricView extends StatelessWidget {
  const HorizontalLyricView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: ListenableBuilder(
        listenable: PlayService.instance.lyricService,
        builder: (context, _) => FutureBuilder(
          future: PlayService.instance.lyricService.currLyricFuture,
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Enjoy Music",
                    style: TextStyle(color: scheme.onSecondaryContainer),
                  ),
                ),
              );
            }

            return _LyricHorizontalScrollArea(snapshot.data!);
          },
        ),
      ),
    );
  }
}

class _LyricHorizontalScrollArea extends StatefulWidget {
  const _LyricHorizontalScrollArea(this.lyric);

  final Lyric lyric;

  @override
  State<_LyricHorizontalScrollArea> createState() =>
      _LyricHorizontalScrollAreaState();
}

class _LyricHorizontalScrollAreaState
    extends State<_LyricHorizontalScrollArea> {
  /// 停留300ms后启动，提前300ms滚动到底
  final waitFor = const Duration(milliseconds: 300);
  final scrollController = ScrollController();
  final lyricService = PlayService.instance.lyricService;
  late StreamSubscription lyricLineStreamSubscription;

  var currContent = "Enjoy Music";

  @override
  void initState() {
    super.initState();
    if (widget.lyric.lines.isNotEmpty) {
      final first = widget.lyric.lines.first;
      if (first is LrcLine) {
        currContent = first.content;
      } else if (first is SyncLyricLine) {
        currContent = first.translation == null
            ? first.content
            : "${first.content}┃${first.translation}";
      }
    }

    lyricLineStreamSubscription = lyricService.lyricLineStream.listen((line) {
      if (widget.lyric.lines.isEmpty) return;
      final currLine = widget.lyric.lines[line];

      setState(() {
        if (currLine is LrcLine) {
          currContent = currLine.content;
        } else if (currLine is SyncLyricLine) {
          currContent = currLine.translation == null
              ? currLine.content
              : "${currLine.content}┃${currLine.translation}";
        }
      });

      /// 减去启动延时和滚动结束停留时间
      late final Duration lastTime;
      if (currLine is LrcLine) {
        lastTime = currLine.length - waitFor - waitFor;
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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SingleChildScrollView(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            currContent,
            style: TextStyle(color: scheme.onSecondaryContainer),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    lyricLineStreamSubscription.cancel();
    scrollController.dispose();
  }
}
