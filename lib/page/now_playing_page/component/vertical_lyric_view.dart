import 'dart:async';
import 'dart:math';

import 'package:coriander_player/lyric.dart';
import 'package:coriander_player/play_service.dart';
import 'package:coriander_player/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  List<_LyricViewTile>? lyricTiles;

  /// 用来定位到当前歌词
  final currentLyricTileKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _initLyricView();

    playService.addListener(_updateLyric);
    lyricLineStreamSubscription =
        playService.lyricLineStream.listen(_updateNextLyricLine);
  }

  /// 加载当前歌词页面，获取并滚动到当前歌词行的位置
  void _initLyricView() {
    lyric = playService.nowPlayingLyric;
    if (lyric == null) {
      lyricTiles = [
        _LyricViewTile(
          line: LyricLine(time: Duration.zero, content: "Enjoy Music"),
          opacity: 1.0,
        )
      ];
    } else {
      final next = lyric!.lines.indexWhere(
        (element) => element.time.inMilliseconds / 1000 > playService.position,
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
    PlayService.instance.seek(lyric!.lines[i].time.inMilliseconds / 1000);
    setState(() {
      lyricTiles = _generateLyricTiles(i);
    });
  }

  /// 当前歌词行100%透明度，上一句和下一句55%，其余10%
  /// 把[currentLyricTileKey]绑在当前歌词行上
  List<_LyricViewTile> _generateLyricTiles(int lyricLine) {
    return List.generate(
      lyric!.lines.length,
      (i) {
        if (lyricLine >= 2 && i <= lyricLine - 2) {
          return _LyricViewTile(
            line: lyric!.lines[i],
            opacity: 0.10,
            onTap: () => _seekToLyricLine(i),
          );
        }
        if (lyricLine >= 1 && i == lyricLine - 1) {
          return _LyricViewTile(
            line: lyric!.lines[i],
            opacity: 0.55,
            onTap: () => _seekToLyricLine(i),
          );
        }
        if (lyricLine < lyric!.lines.length - 1 && i == lyricLine + 1) {
          return _LyricViewTile(
            line: lyric!.lines[i],
            opacity: 0.55,
            onTap: () => _seekToLyricLine(i),
          );
        }
        if (lyricLine < lyric!.lines.length - 2 && i >= lyricLine + 2) {
          return _LyricViewTile(
            line: lyric!.lines[i],
            opacity: 0.10,
            onTap: () => _seekToLyricLine(i),
          );
        }
        return _LyricViewTile(
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
    lyric = playService.nowPlayingLyric;
    if (lyric == null) {
      lyricTiles = [
        _LyricViewTile(
          line: LyricLine(time: Duration.zero, content: "Enjoy Music"),
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
    final theme = Provider.of<ThemeProvider>(context);
    if (lyricTiles == null) {
      return Center(
        child: Text(
          "Not Playing",
          style: TextStyle(color: theme.palette.onSecondaryContainer),
        ),
      );
    }

    return Material(
      type: MaterialType.transparency,
      child: ScrollConfiguration(
        behavior: scrollBehavier,
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: lyricTiles!,
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

class _LyricViewTile extends StatelessWidget {
  const _LyricViewTile(
      {super.key, required this.line, required this.opacity, this.onTap});

  final LyricLine line;
  final double opacity;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    final texts = line.content.split("┃");
    final List<Text> textTiles = [
      Text(
        texts.first,
        style: TextStyle(
          color: theme.palette.onSecondaryContainer,
          fontSize: 22.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    ];
    for (var i = 1; i < texts.length; i++) {
      textTiles.add(Text(
        texts[i],
        style: TextStyle(
          color: theme.palette.onSecondaryContainer,
          fontSize: 18.0,
        ),
      ));
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: Opacity(
        opacity: opacity,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.0),
          hoverColor: theme.palette.onSecondaryContainer.withOpacity(0.08),
          highlightColor: theme.palette.onSecondaryContainer.withOpacity(0.12),
          splashColor: theme.palette.onSecondaryContainer.withOpacity(0.12),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: textTiles,
            ),
          ),
        ),
      ),
    );
  }
}
