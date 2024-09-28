import 'dart:async';
import 'dart:math';

import 'package:coriander_player/lyric/lrc.dart';
import 'package:coriander_player/lyric/lyric.dart';
import 'package:coriander_player/page/now_playing_page/component/lyric_view_controls.dart';
import 'package:coriander_player/play_service/play_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

class LyricViewTile extends StatelessWidget {
  const LyricViewTile(
      {super.key, required this.line, required this.opacity, this.onTap});

  final LyricLine line;
  final double opacity;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final lyricViewController = context.watch<LyricViewController>();
    return Align(
      alignment: switch (lyricViewController.lyricTextAlign) {
        LyricTextAlign.left => Alignment.centerLeft,
        LyricTextAlign.center => Alignment.center,
        LyricTextAlign.right => Alignment.centerRight,
      },
      child: Opacity(
        opacity: opacity,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.0),
          child: line is SyncLyricLine
              ? _SyncLineContent(
                  syncLine: line as SyncLyricLine,
                  isMainLine: opacity == 1.0,
                )
              : _LrcLineContent(
                  lrcLine: line as LrcLine,
                  isMainLine: opacity == 1.0,
                ),
        ),
      ),
    );
  }
}

class _SyncLineContent extends StatelessWidget {
  const _SyncLineContent(
      {required this.syncLine, required this.isMainLine});

  final SyncLyricLine syncLine;
  final bool isMainLine;

  @override
  Widget build(BuildContext context) {
    if (syncLine.words.isEmpty) {
      if (syncLine.length > const Duration(seconds: 5) && isMainLine) {
        return LyricTransitionTile(syncLine: syncLine);
      } else {
        return const SizedBox.shrink();
      }
    }

    final scheme = Theme.of(context).colorScheme;
    final lyricViewController = context.watch<LyricViewController>();

    final lyricFontSize = lyricViewController.lyricFontSize;
    final translationFontSize = lyricViewController.translationFontSize;
    final alignment = lyricViewController.lyricTextAlign;

    if (!isMainLine) {
      if (syncLine.words.isEmpty) {
        return const SizedBox.shrink();
      }

      final List<Text> contents = [
        buildPrimaryText(syncLine.content, scheme, alignment, lyricFontSize),
      ];
      if (syncLine.translation != null) {
        contents.add(buildSecondaryText(
          syncLine.translation!,
          scheme,
          alignment,
          translationFontSize,
        ));
      }

      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: switch (alignment) {
            LyricTextAlign.left => CrossAxisAlignment.start,
            LyricTextAlign.center => CrossAxisAlignment.center,
            LyricTextAlign.right => CrossAxisAlignment.end,
          },
          children: contents,
        ),
      );
    }

    final List<Widget> contents = [
      StreamBuilder(
        stream: PlayService.instance.playbackService.positionStream,
        builder: (context, snapshot) {
          final posInMs = (snapshot.data ?? 0) * 1000;
          return RichText(
            textAlign: switch (alignment) {
              LyricTextAlign.left => TextAlign.left,
              LyricTextAlign.center => TextAlign.center,
              LyricTextAlign.right => TextAlign.right,
            },
            text: TextSpan(
              children: List.generate(
                syncLine.words.length,
                (i) {
                  final posFromWordStart = max(
                    posInMs - syncLine.words[i].start.inMilliseconds,
                    0,
                  );
                  final progress = min(
                    posFromWordStart / syncLine.words[i].length.inMilliseconds,
                    1.0,
                  );
                  return WidgetSpan(
                    child: ShaderMask(
                      blendMode: BlendMode.dstIn,
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          colors: [
                            scheme.primary,
                            scheme.primary,
                            scheme.primary.withOpacity(0.10),
                            scheme.primary.withOpacity(0.10),
                          ],
                          stops: [0, progress, progress, 1],
                        ).createShader(bounds);
                      },
                      child: Text(
                        syncLine.words[i].content,
                        style: TextStyle(
                          color: scheme.primary,
                          fontSize: lyricFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      )
    ];
    if (syncLine.translation != null) {
      contents.add(buildSecondaryText(
        syncLine.translation!,
        scheme,
        alignment,
        translationFontSize,
      ));
    }
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: switch (alignment) {
          LyricTextAlign.left => CrossAxisAlignment.start,
          LyricTextAlign.center => CrossAxisAlignment.center,
          LyricTextAlign.right => CrossAxisAlignment.end,
        },
        children: contents,
      ),
    );
  }

  Text buildPrimaryText(
    String text,
    ColorScheme scheme,
    LyricTextAlign align,
    double fontSize,
  ) {
    return Text(
      text,
      textAlign: switch (align) {
        LyricTextAlign.left => TextAlign.left,
        LyricTextAlign.center => TextAlign.center,
        LyricTextAlign.right => TextAlign.right,
      },
      style: TextStyle(
        color: scheme.onSecondaryContainer,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Text buildSecondaryText(
    String text,
    ColorScheme scheme,
    LyricTextAlign align,
    double fontSize,
  ) {
    return Text(
      text,
      textAlign: switch (align) {
        LyricTextAlign.left => TextAlign.left,
        LyricTextAlign.center => TextAlign.center,
        LyricTextAlign.right => TextAlign.right,
      },
      style: TextStyle(color: scheme.onSecondaryContainer, fontSize: fontSize),
    );
  }
}

class _LrcLineContent extends StatelessWidget {
  const _LrcLineContent(
      {required this.lrcLine, required this.isMainLine});

  final LrcLine lrcLine;
  final bool isMainLine;

  @override
  Widget build(BuildContext context) {
    if (lrcLine.isBlank) {
      if (lrcLine.length > const Duration(seconds: 5) && isMainLine) {
        return LyricTransitionTile(lrcLine: lrcLine);
      } else {
        return const SizedBox.shrink();
      }
    }

    final scheme = Theme.of(context).colorScheme;
    final lyricViewController = context.watch<LyricViewController>();

    final lyricFontSize = lyricViewController.lyricFontSize;
    final translationFontSize = lyricViewController.translationFontSize;
    final alignment = lyricViewController.lyricTextAlign;

    final splited = lrcLine.content.split("┃");
    final List<Text> contents = [
      buildPrimaryText(splited.first, scheme, alignment, lyricFontSize),
    ];
    for (var i = 1; i < splited.length; i++) {
      contents.add(buildSecondaryText(
        splited[i],
        scheme,
        alignment,
        translationFontSize,
      ));
    }

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: switch (alignment) {
          LyricTextAlign.left => CrossAxisAlignment.start,
          LyricTextAlign.center => CrossAxisAlignment.center,
          LyricTextAlign.right => CrossAxisAlignment.end,
        },
        children: contents,
      ),
    );
  }

  Text buildPrimaryText(
    String text,
    ColorScheme scheme,
    LyricTextAlign align,
    double fontSize,
  ) {
    return Text(
      text,
      textAlign: switch (align) {
        LyricTextAlign.left => TextAlign.left,
        LyricTextAlign.center => TextAlign.center,
        LyricTextAlign.right => TextAlign.right,
      },
      style: TextStyle(
        color: scheme.onSecondaryContainer,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Text buildSecondaryText(
    String text,
    ColorScheme scheme,
    LyricTextAlign align,
    double fontSize,
  ) {
    return Text(
      text,
      textAlign: switch (align) {
        LyricTextAlign.left => TextAlign.left,
        LyricTextAlign.center => TextAlign.center,
        LyricTextAlign.right => TextAlign.right,
      },
      style: TextStyle(color: scheme.onSecondaryContainer, fontSize: fontSize),
    );
  }
}

/// 歌词间奏表示
/// lrcLine 和 syncLine 必须有且只有一个不为空
class LyricTransitionTile extends StatelessWidget {
  final LrcLine? lrcLine;
  final SyncLyricLine? syncLine;
  const LyricTransitionTile({super.key, this.lrcLine, this.syncLine});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 40.0,
      width: 80.0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 18, 12, 6),
        child: CustomPaint(
          painter: LyricTransitionPainter(
            scheme,
            LyricTransitionTileController(lrcLine, syncLine),
          ),
        ),
      ),
    );
  }
}

class LyricTransitionPainter extends CustomPainter {
  final ColorScheme scheme;
  final LyricTransitionTileController controller;

  final Paint circlePaint1 = Paint();
  final Paint circlePaint2 = Paint();
  final Paint circlePaint3 = Paint();

  final double radius = 6;

  LyricTransitionPainter(this.scheme, this.controller)
      : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    circlePaint1.color = scheme.onSecondaryContainer.withOpacity(
      0.05 + min(controller.progress * 3, 1) * 0.95,
    );
    circlePaint2.color = scheme.onSecondaryContainer.withOpacity(
      0.05 + min(max(controller.progress - 1 / 3, 0) * 3, 1) * 0.95,
    );
    circlePaint3.color = scheme.onSecondaryContainer.withOpacity(
      0.05 + min(max(controller.progress - 2 / 3, 0) * 3, 1) * 0.95,
    );

    final rWithFactor = radius + controller.sizeFactor;
    final c1 = Offset(rWithFactor, 8);
    final c2 = Offset(4 * rWithFactor, 8);
    final c3 = Offset(7 * rWithFactor, 8);

    canvas.drawCircle(c1, rWithFactor, circlePaint1);
    canvas.drawCircle(c2, rWithFactor, circlePaint2);
    canvas.drawCircle(c3, rWithFactor, circlePaint3);
  }

  @override
  bool shouldRepaint(LyricTransitionPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(LyricTransitionPainter oldDelegate) => false;
}

class LyricTransitionTileController extends ChangeNotifier {
  final LrcLine? lrcLine;
  final SyncLyricLine? syncLine;

  final playbackService = PlayService.instance.playbackService;

  double progress = 0;
  late final StreamSubscription positionStreamSub;

  double sizeFactor = 0;
  double k = 1;
  late final Ticker factorTicker;

  LyricTransitionTileController([this.lrcLine, this.syncLine]) {
    positionStreamSub = playbackService.positionStream.listen(_updateProgress);
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
    late int startInMs;
    late int lengthInMs;
    if (lrcLine != null) {
      startInMs = lrcLine!.start.inMilliseconds;
      lengthInMs = lrcLine!.length.inMilliseconds;
    } else {
      startInMs = syncLine!.start.inMilliseconds;
      lengthInMs = syncLine!.length.inMilliseconds;
    }
    final sinceStart = position * 1000 - startInMs;
    progress = max(sinceStart, 0) / lengthInMs;
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
