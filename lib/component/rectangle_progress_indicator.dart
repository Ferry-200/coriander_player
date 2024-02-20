import 'dart:async';
import 'dart:math' as math;
import 'package:coriander_player/play_service.dart';
import 'package:coriander_player/theme/color_palette.dart';
import 'package:coriander_player/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    subscription = PlayService.instance.positionStream.listen((event) {
      progress.value = event / PlayService.instance.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    return CustomPaint(
      size: widget.size,
      painter: RectangleProgressPainter(
        progress: progress,
        palette: theme.palette,
      ),
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

  final ColorPalette palette;

  RectangleProgressPainter({required this.progress, required this.palette})
      : super(repaint: progress);

  @override
  void paint(Canvas canvas, Size size) {
    final progressPainter = Paint();
    progressPainter.color = palette.secondaryContainer;

    final trackPainter = Paint();
    trackPainter.color = palette.surfaceContainer;

    /// 进度条背景
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          0.0,
          0.0,
          size.width,
          size.height,
        ),
        const Radius.circular(12.0),
      ),
      trackPainter,
    );

    /// 填充圆角矩形：
    /// 1. 求出当前填充的进度，用圆角半径减去
    /// 2. 求出当前位置下矩形的实际高度
    /// 3. 在矩形实际的左上顶点填充，圆角为h
    final a = 12 - (size.width * progress.value);

    final h = math.sqrt(math.pow(12, 2) - math.pow(a > 0 ? a : 0, 2));
    final height = size.height - 2 * (12 - h);

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(0.0, 12 - h, size.width * progress.value, height),
        topLeft: Radius.circular(h),
        topRight: const Radius.circular(12.0),
        bottomLeft: Radius.circular(h),
        bottomRight: const Radius.circular(12.0),
      ),
      progressPainter,
    );
  }

  @override
  bool shouldRepaint(RectangleProgressPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(RectangleProgressPainter oldDelegate) => false;
}
