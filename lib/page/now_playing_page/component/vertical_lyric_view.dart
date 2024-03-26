import 'dart:async';
import 'dart:math';

import 'package:coriander_player/lyric/lrc.dart';
import 'package:coriander_player/lyric/lyric.dart';
import 'package:coriander_player/page/now_playing_page/component/lyric_source_label.dart';
import 'package:coriander_player/page/now_playing_page/component/lyric_view_tile.dart';
import 'package:coriander_player/play_service.dart';
import 'package:flutter/material.dart';

class VerticalLyricView extends StatefulWidget {
  const VerticalLyricView({super.key});

  @override
  State<VerticalLyricView> createState() => _VerticalLyricViewState();
}

class _VerticalLyricViewState extends State<VerticalLyricView> {
  final playService = PlayService.instance;
  late StreamSubscription lyricLineStreamSubscription;
  final scrollController = ScrollController();

  /// 隐藏滚动条
  final scrollBehavier = const ScrollBehavior().copyWith(scrollbars: false);

  Lyric? lyric;
  List<LyricViewTile> lyricTiles = [
    LyricViewTile(line: LrcLine.defaultLine, opacity: 1.0)
  ];

  /// 用来定位到当前歌词
  final currentLyricTileKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _initLyricView();

    playService.currentLyric.addListener(_updateLyric);
    lyricLineStreamSubscription =
        playService.lyricLineStream.listen(_updateNextLyricLine);
  }

  /// 加载当前歌词页面，获取并滚动到当前歌词行的位置
  void _initLyricView() {
    lyric = playService.currentLyric.value;
    if (lyric == null) {
      lyricTiles = [LyricViewTile(line: LrcLine.defaultLine, opacity: 1.0)];
    } else {
      final next = lyric!.lines.indexWhere(
        (element) => element.start.inMilliseconds / 1000 > playService.position,
      );
      int nextLyricLine = next == -1 ? lyric!.lines.length : next;
      lyricTiles = _generateLyricTiles(max(nextLyricLine - 1, 0));

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        final targetContext = currentLyricTileKey.currentContext;
        if (targetContext == null) return;

        /// scroll to curr lyric line
        if (targetContext.mounted) {
          Scrollable.ensureVisible(
            targetContext,
            alignment: 0.25,
            duration: const Duration(milliseconds: 300),
            curve: Curves.fastOutSlowIn,
          );
        }
      });
    }
  }

  void _seekToLyricLine(int i) {
    PlayService.instance.seek(lyric!.lines[i].start.inMilliseconds / 1000);
    setState(() {
      lyricTiles = _generateLyricTiles(i);
    });
  }

  /// 当前歌词行100%透明度，上一句和下一句55%，其余10%
  /// 把[currentLyricTileKey]绑在当前歌词行上
  List<LyricViewTile> _generateLyricTiles(int mainLine) {
    return List.generate(
      lyric!.lines.length,
      (i) {
        if (mainLine >= 2 && i <= mainLine - 2) {
          return LyricViewTile(
            line: lyric!.lines[i],
            opacity: 0.10,
            onTap: () => _seekToLyricLine(i),
          );
        }
        if (mainLine >= 1 && i == mainLine - 1) {
          return LyricViewTile(
            line: lyric!.lines[i],
            opacity: 0.55,
            onTap: () => _seekToLyricLine(i),
          );
        }
        if (mainLine < lyric!.lines.length - 1 && i == mainLine + 1) {
          return LyricViewTile(
            line: lyric!.lines[i],
            opacity: 0.55,
            onTap: () => _seekToLyricLine(i),
          );
        }
        if (mainLine < lyric!.lines.length - 2 && i >= mainLine + 2) {
          return LyricViewTile(
            line: lyric!.lines[i],
            opacity: 0.10,
            onTap: () => _seekToLyricLine(i),
          );
        }
        return LyricViewTile(
          key: currentLyricTileKey,
          line: lyric!.lines[i],
          opacity: 1.0,
          onTap: () => _seekToLyricLine(i),
        );
      },
    );
  }

  /// 重新获取歌词
  void _updateLyric() {
    lyric = playService.currentLyric.value;
    if (lyric == null) {
      lyricTiles = [
        LyricViewTile(
          line: LrcLine.defaultLine,
          opacity: 1.0,
          onTap: () {},
        )
      ];
    } else {
      lyricTiles = _generateLyricTiles(0);
    }
    setState(() {});
    scrollController.jumpTo(0);
  }

  void _updateNextLyricLine(int lyricLine) {
    if (lyric == null) return;

    lyricTiles = _generateLyricTiles(lyricLine);
    setState(() {});

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final targetContext = currentLyricTileKey.currentContext;
      if (targetContext == null) return;

      /// scroll to curr lyric line
      if (targetContext.mounted) {
        Scrollable.ensureVisible(
          targetContext,
          alignment: 0.25,
          duration: const Duration(milliseconds: 300),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Material(
          type: MaterialType.transparency,
          child: ScrollConfiguration(
            behavior: scrollBehavier,
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: lyricTiles,
              ),
            ),
          ),
        ),
        const LyricSourceLabel()
      ],
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