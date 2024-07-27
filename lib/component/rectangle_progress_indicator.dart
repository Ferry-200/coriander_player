import 'dart:async';
import 'package:coriander_player/play_service/play_service.dart';
import 'package:flutter/material.dart';

class RectangleProgressIndicator extends StatefulWidget {
  const RectangleProgressIndicator({
    super.key,
    required this.size,
    required this.child,
  });

  final Size size;
  final Widget child;

  @override
  State<RectangleProgressIndicator> createState() =>
      _RectangleProgressIndicatorState();
}

class _RectangleProgressIndicatorState
    extends State<RectangleProgressIndicator> {
  /// [positionStream] 的订阅，在dispose取消订阅
  late StreamSubscription<double> subscription;

  /// position / length, [0, 1]
  final progress = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    subscription = PlayService.instance.playbackService.positionStream.listen((event) {
      progress.value = event / PlayService.instance.playbackService.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CustomPaint(
      size: widget.size,
      painter: RectangleProgressPainter(progress: progress, scheme: scheme),
      child: widget.child,
    );
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }
}

class RectangleProgressPainter extends CustomPainter {
  /// position / length, [0, 1]
  final ValueNotifier<double> progress;

  final ColorScheme scheme;

  RectangleProgressPainter({required this.progress, required this.scheme})
      : super(repaint: progress);

  @override
  void paint(Canvas canvas, Size size) {
    final progressPainter = Paint();
    progressPainter.color = scheme.secondaryContainer;

    final trackPainter = Paint();
    trackPainter.color = scheme.surfaceContainer;

    /// 进度条背景
    canvas.drawRect(
      Rect.fromLTWH(0.0, 0.0, size.width, size.height),
      trackPainter,
    );

    /// 进度
    canvas.drawRect(
      Rect.fromLTWH(0.0, 0.0, size.width * progress.value, size.height),
      progressPainter,
    );
  }

  @override
  bool shouldRepaint(RectangleProgressPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(RectangleProgressPainter oldDelegate) => false;
}
