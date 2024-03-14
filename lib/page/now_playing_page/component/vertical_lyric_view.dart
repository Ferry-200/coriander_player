import 'dart:async';
import 'dart:math';

import 'package:coriander_player/lyric/lrc.dart';
import 'package:coriander_player/play_service.dart';
import 'package:coriander_player/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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

  Lrc? lyric;
  late List<_LyricViewTile> lyricTiles;

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
          line: LrcLine.blankLine,
          opacity: 1.0,
        )
      ];
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
  List<_LyricViewTile> _generateLyricTiles(int lyricLine) {
    return List.generate(
      lyric!.lines.length,
      (i) {
        if (lyricLine >= 2 && i <= lyricLine - 2) {
          return _LyricViewTile(
            line: lyric!.lines[i] as LrcLine,
            opacity: 0.10,
            onTap: () => _seekToLyricLine(i),
          );
        }
        if (lyricLine >= 1 && i == lyricLine - 1) {
          return _LyricViewTile(
            line: lyric!.lines[i] as LrcLine,
            opacity: 0.55,
            onTap: () => _seekToLyricLine(i),
          );
        }
        if (lyricLine < lyric!.lines.length - 1 && i == lyricLine + 1) {
          return _LyricViewTile(
            line: lyric!.lines[i] as LrcLine,
            opacity: 0.55,
            onTap: () => _seekToLyricLine(i),
          );
        }
        if (lyricLine < lyric!.lines.length - 2 && i >= lyricLine + 2) {
          return _LyricViewTile(
            line: lyric!.lines[i] as LrcLine,
            opacity: 0.10,
            onTap: () => _seekToLyricLine(i),
          );
        }
        return _LyricViewTile(
          key: currentLyricTileKey,
          line: lyric!.lines[i] as LrcLine,
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
          line: LrcLine.blankLine,
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
    playService.removeListener(_updateLyric);
    scrollController.dispose();
  }
}

class LyricSourceLabel extends StatelessWidget {
  const LyricSourceLabel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final playService = Provider.of<PlayService>(context);
    final lyric = playService.nowPlayingLyric;

    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
            border: Border.all(color: theme.palette.outline),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              lyric == null
                  ? "无"
                  : lyric.lines.isEmpty
                      ? "歌词为空"
                      : lyric.source.name,
              style: TextStyle(
                fontSize: 12,
                color: theme.palette.onSecondaryContainer,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LyricViewTile extends StatelessWidget {
  const _LyricViewTile(
      {super.key, required this.line, required this.opacity, this.onTap});

  final LrcLine line;
  final double opacity;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    if (line.isBlank) {
      if (line.length > const Duration(seconds: 5) && opacity == 1.0) {
        return _LyricCountDownTile(line: line);
      } else {
        return const SizedBox();
      }
    }

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

class _LyricCountDownTile extends StatelessWidget {
  final LrcLine line;
  const _LyricCountDownTile({required this.line});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        height: 40.0,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 18, 12, 6),
          child: CustomPaint(
            painter: CountDownTilePainter(
              theme,
              CountDownTileController(line),
            ),
          ),
        ),
      ),
    );
  }
}

class CountDownTilePainter extends CustomPainter {
  final ThemeProvider theme;
  final CountDownTileController controller;

  final Paint foregroundPaint1 = Paint();
  final Paint foregroundPaint2 = Paint();
  final Paint foregroundPaint3 = Paint();

  final double radius = 6;

  CountDownTilePainter(this.theme, this.controller)
      : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    foregroundPaint1.color = theme.palette.onSecondaryContainer.withOpacity(
      0.05 + min(controller.progress * 3, 1) * 0.95,
    );
    foregroundPaint2.color = theme.palette.onSecondaryContainer.withOpacity(
      0.05 + min(max(controller.progress - 1 / 3, 0) * 3, 1) * 0.95,
    );
    foregroundPaint3.color = theme.palette.onSecondaryContainer.withOpacity(
      0.05 + min(max(controller.progress - 2 / 3, 0) * 3, 1) * 0.95,
    );

    final rWithFactor = radius + controller.sizeFactor;
    final c1 = Offset(rWithFactor, 8);
    final c2 = Offset(4 * rWithFactor, 8);
    final c3 = Offset(7 * rWithFactor, 8);

    canvas.drawCircle(c1, rWithFactor, foregroundPaint1);
    canvas.drawCircle(c2, rWithFactor, foregroundPaint2);
    canvas.drawCircle(c3, rWithFactor, foregroundPaint3);
  }

  @override
  bool shouldRepaint(CountDownTilePainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(CountDownTilePainter oldDelegate) => false;
}

class CountDownTileController extends ChangeNotifier {
  final LrcLine line;

  final playService = PlayService.instance;

  double progress = 0;
  late final StreamSubscription positionStreamSub;

  double sizeFactor = 0;
  double k = 1;
  late final Ticker factorTicker;

  CountDownTileController(this.line) {
    positionStreamSub = playService.positionStream.listen(_updateProgress);
    factorTicker = Ticker((elapsed) {
      sizeFactor += k * 1 / 180;
      if (sizeFactor > 1) {
        k = -1;
        sizeFactor = 1;
      } else if (sizeFactor < 0) {
        k = 1;
        sizeFactor = 0;
      }
      notifyListeners();
    });
    factorTicker.start();
  }

  void _updateProgress(double position) {
    final sinceStart = position * 1000 - line.start.inMilliseconds;
    progress = max(sinceStart, 0) / line.length.inMilliseconds;
    notifyListeners();

    if (progress >= 1) {
      dispose();
    }
  }

  @override
  void dispose() {
    positionStreamSub.cancel();
    factorTicker.dispose();
    super.dispose();
  }
}
