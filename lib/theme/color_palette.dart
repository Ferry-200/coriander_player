import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'dart:ui' as ui;

/// Material的ColorScheme没有[surfaceContainer]等属性。
/// 这些值可以由CorePalette的neutral.get方法获取。该类暴露了这些方法（ColorScheme不存储corePalette），易于拓展。
class ColorPalette {
  CorePalette palette;

  int seed;
  Brightness brightness;

  ui.Color surface;
  ui.Color primary;
  ui.Color secondary;

  ui.Color onSurface;
  ui.Color onSurfaceVariant;
  ui.Color onPrimary;
  ui.Color onSecondary;

  ui.Color surfaceContainer;
  ui.Color primaryContainer;
  ui.Color secondaryContainer;

  ui.Color onPrimaryContainer;
  ui.Color onSecondaryContainer;

  ui.Color outline;
  ui.Color outlineVariant;

  ui.Color error;
  ui.Color onError;

  ColorPalette(
    this.palette, {
    required this.seed,
    required this.brightness,
    required this.surface,
    required this.primary,
    required this.secondary,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.onPrimary,
    required this.onSecondary,
    required this.surfaceContainer,
    required this.primaryContainer,
    required this.secondaryContainer,
    required this.onPrimaryContainer,
    required this.onSecondaryContainer,
    required this.outline,
    required this.outlineVariant,
    required this.error,
    required this.onError,
  });

  factory ColorPalette.fromSeed({
    int seedValue = 4290545753,
    Brightness brightness = Brightness.light,
  }) {
    final palette = CorePalette.of(seedValue);

    return brightness == Brightness.light
        ? ColorPalette(
            palette,
            seed: seedValue,
            brightness: Brightness.light,
            surface: ui.Color(palette.neutral.get(98)),
            primary: ui.Color(palette.primary.get(40)),
            secondary: ui.Color(palette.secondary.get(40)),
            onSurface: ui.Color(palette.neutral.get(10)),
            onSurfaceVariant: ui.Color(palette.neutralVariant.get(30)),
            onPrimary: ui.Color(palette.primary.get(100)),
            onSecondary: ui.Color(palette.secondary.get(100)),
            surfaceContainer: ui.Color(palette.neutral.get(94)),
            primaryContainer: ui.Color(palette.primary.get(90)),
            secondaryContainer: ui.Color(palette.secondary.get(90)),
            onPrimaryContainer: ui.Color(palette.primary.get(10)),
            onSecondaryContainer: ui.Color(palette.secondary.get(10)),
            outline: ui.Color(palette.neutralVariant.get(50)),
            outlineVariant: ui.Color(palette.neutralVariant.get(80)),
            error: ui.Color(palette.error.get(40)),
            onError: ui.Color(palette.error.get(100)),
          )
        : ColorPalette(
            palette,
            seed: seedValue,
            brightness: Brightness.dark,
            surface: ui.Color(palette.neutral.get(6)),
            primary: ui.Color(palette.primary.get(80)),
            secondary: ui.Color(palette.secondary.get(80)),
            onSurface: ui.Color(palette.neutral.get(90)),
            onSurfaceVariant: ui.Color(palette.neutralVariant.get(80)),
            onPrimary: ui.Color(palette.primary.get(20)),
            onSecondary: ui.Color(palette.secondary.get(20)),
            surfaceContainer: ui.Color(palette.neutral.get(12)),
            primaryContainer: ui.Color(palette.primary.get(30)),
            secondaryContainer: ui.Color(palette.secondary.get(30)),
            onPrimaryContainer: ui.Color(palette.primary.get(90)),
            onSecondaryContainer: ui.Color(palette.secondary.get(90)),
            outline: ui.Color(palette.neutralVariant.get(60)),
            outlineVariant: ui.Color(palette.neutralVariant.get(30)),
            error: ui.Color(palette.error.get(80)),
            onError: ui.Color(palette.error.get(20)),
          );
  }

  static Future<ColorPalette> fromImageProvider({
    required ImageProvider provider,
    Brightness brightness = Brightness.light,
  }) async {
    // Extract dominant colors from image.
    final QuantizerResult quantizerResult =
        await _extractColorsFromImageProvider(provider);
    final Map<int, int> colorToCount = quantizerResult.colorToCount.map(
      (int key, int value) => MapEntry<int, int>(_getArgbFromAbgr(key), value),
    );

    // Score colors for color scheme suitability.
    final List<int> scoredResults = Score.score(colorToCount, desired: 1);

    final palette = CorePalette.of(scoredResults.first);

    return brightness == Brightness.light
        ? ColorPalette(
            palette,
            seed: scoredResults.first,
            brightness: Brightness.light,
            surface: ui.Color(palette.neutral.get(98)),
            primary: ui.Color(palette.primary.get(40)),
            secondary: ui.Color(palette.secondary.get(40)),
            onSurface: ui.Color(palette.neutral.get(10)),
            onSurfaceVariant: ui.Color(palette.neutralVariant.get(30)),
            onPrimary: ui.Color(palette.primary.get(100)),
            onSecondary: ui.Color(palette.secondary.get(100)),
            surfaceContainer: ui.Color(palette.neutral.get(94)),
            primaryContainer: ui.Color(palette.primary.get(90)),
            secondaryContainer: ui.Color(palette.secondary.get(90)),
            onPrimaryContainer: ui.Color(palette.primary.get(10)),
            onSecondaryContainer: ui.Color(palette.secondary.get(10)),
            outline: ui.Color(palette.neutralVariant.get(50)),
            outlineVariant: ui.Color(palette.neutralVariant.get(80)),
            error: ui.Color(palette.error.get(40)),
            onError: ui.Color(palette.error.get(100)),
          )
        : ColorPalette(
            palette,
            seed: scoredResults.first,
            brightness: Brightness.dark,
            surface: ui.Color(palette.neutral.get(6)),
            primary: ui.Color(palette.primary.get(80)),
            secondary: ui.Color(palette.secondary.get(80)),
            onSurface: ui.Color(palette.neutral.get(90)),
            onSurfaceVariant: ui.Color(palette.neutralVariant.get(80)),
            onPrimary: ui.Color(palette.primary.get(20)),
            onSecondary: ui.Color(palette.secondary.get(20)),
            surfaceContainer: ui.Color(palette.neutral.get(12)),
            primaryContainer: ui.Color(palette.primary.get(30)),
            secondaryContainer: ui.Color(palette.secondary.get(30)),
            onPrimaryContainer: ui.Color(palette.primary.get(90)),
            onSecondaryContainer: ui.Color(palette.secondary.get(90)),
            outline: ui.Color(palette.neutralVariant.get(60)),
            outlineVariant: ui.Color(palette.neutralVariant.get(30)),
            error: ui.Color(palette.error.get(80)),
            onError: ui.Color(palette.error.get(20)),
          );
  }

  /// Extracts bytes from an [ImageProvider] and returns a [QuantizerResult]
  /// containing the most dominant colors.
  /// copy from [ColorScheme]
  static Future<QuantizerResult> _extractColorsFromImageProvider(
      ImageProvider imageProvider) async {
    final ui.Image scaledImage = await _imageProviderToScaled(imageProvider);
    final ByteData? imageBytes = await scaledImage.toByteData();

    final QuantizerResult quantizerResult = await QuantizerCelebi().quantize(
      imageBytes!.buffer.asUint32List(),
      128,
      returnInputPixelToClusterPixel: true,
    );
    return quantizerResult;
  }

  /// Scale image size down to reduce computation time of color extraction.
  /// copy form [ColorScheme]
  static Future<ui.Image> _imageProviderToScaled(
      ImageProvider imageProvider) async {
    const double maxDimension = 112.0;
    final ImageStream stream = imageProvider.resolve(
        const ImageConfiguration(size: Size(maxDimension, maxDimension)));
    final Completer<ui.Image> imageCompleter = Completer<ui.Image>();
    late ImageStreamListener listener;
    late ui.Image scaledImage;
    Timer? loadFailureTimeout;

    listener = ImageStreamListener((ImageInfo info, bool sync) async {
      loadFailureTimeout?.cancel();
      stream.removeListener(listener);
      final ui.Image image = info.image;
      final int width = image.width;
      final int height = image.height;
      double paintWidth = width.toDouble();
      double paintHeight = height.toDouble();
      assert(width > 0 && height > 0);

      final bool rescale = width > maxDimension || height > maxDimension;
      if (rescale) {
        paintWidth =
            (width > height) ? maxDimension : (maxDimension / height) * width;
        paintHeight =
            (height > width) ? maxDimension : (maxDimension / width) * height;
      }
      final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(pictureRecorder);
      paintImage(
          canvas: canvas,
          rect: Rect.fromLTRB(0, 0, paintWidth, paintHeight),
          image: image,
          filterQuality: FilterQuality.none);

      final ui.Picture picture = pictureRecorder.endRecording();
      scaledImage =
          await picture.toImage(paintWidth.toInt(), paintHeight.toInt());
      imageCompleter.complete(info.image);
    }, onError: (Object exception, StackTrace? stackTrace) {
      stream.removeListener(listener);
      throw Exception('Failed to render image: $exception');
    });

    loadFailureTimeout = Timer(const Duration(seconds: 5), () {
      stream.removeListener(listener);
      imageCompleter.completeError(
          TimeoutException('Timeout occurred trying to load image'));
    });

    stream.addListener(listener);
    await imageCompleter.future;
    return scaledImage;
  }

  /// Converts AABBGGRR color int to AARRGGBB format.
  /// copy from [ColorScheme]
  static int _getArgbFromAbgr(int abgr) {
    const int exceptRMask = 0xFF00FFFF;
    const int onlyRMask = ~exceptRMask;
    const int exceptBMask = 0xFFFFFF00;
    const int onlyBMask = ~exceptBMask;
    final int r = (abgr & onlyRMask) >> 16;
    final int b = abgr & onlyBMask;
    return (abgr & exceptRMask & exceptBMask) | (b << 16) | r;
  }
}
